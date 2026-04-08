import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/place_model.dart';
import '../models/comment_model.dart';
import '../models/guide_model.dart';
import '../models/booking_request_model.dart';
import '../models/user_profile_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  User? get currentUser => _auth.currentUser;

  // Auth
  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    return cred;
  }

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // Upload images
  Future<List<String>> uploadImages(List<File> images) async {
    final urls = <String>[];
    for (final image in images) {
      final ref = _storage.ref('places/${_uuid.v4()}.jpg');
      await ref.putFile(image);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  // Places
  Future<void> addPlace(PlaceModel place) =>
      _db.collection('places').doc(place.id).set(place.toMap());

  Stream<List<PlaceModel>> getPlaces({String? category}) {
    Query query = _db
        .collection('places')
        .orderBy('createdAt', descending: true);
    if (category != null) query = query.where('category', isEqualTo: category);
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => PlaceModel.fromFirestore(d)).toList(),
    );
  }

  Future<PlaceModel?> getPlace(String id) async {
    final doc = await _db.collection('places').doc(id).get();
    return doc.exists ? PlaceModel.fromFirestore(doc) : null;
  }

  Future<void> deletePlace(String id) =>
      _db.collection('places').doc(id).delete();

  Stream<List<PlaceModel>> getPlacesByAuthor(String authorId) => _db
      .collection('places')
      .where('authorId', isEqualTo: authorId)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => PlaceModel.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  // Comments & Ratings
  Future<void> addComment(CommentModel comment) async {
    final batch = _db.batch();
    final commentRef = _db.collection('comments').doc(comment.id);
    batch.set(commentRef, comment.toMap());

    // Recalculate average rating
    final placeRef = _db.collection('places').doc(comment.placeId);
    final placeDoc = await placeRef.get();
    if (placeDoc.exists) {
      final data = placeDoc.data()!;
      final oldCount = (data['ratingCount'] ?? 0) as int;
      final oldAvg = (data['averageRating'] ?? 0.0) as double;
      final newCount = oldCount + 1;
      final newAvg = ((oldAvg * oldCount) + comment.rating) / newCount;
      batch.update(placeRef, {
        'averageRating': newAvg,
        'ratingCount': newCount,
        'commentCount': FieldValue.increment(1),
      });
    }
    await batch.commit();
  }

  Stream<List<CommentModel>> getComments(String placeId) => _db
      .collection('comments')
      .where('placeId', isEqualTo: placeId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => CommentModel.fromFirestore(d)).toList(),
      );

  String generateId() => _uuid.v4();

  // Guides
  Future<void> registerAsGuide(GuideModel guide) =>
      _db.collection('guides').doc(guide.id).set(guide.toMap());

  Future<GuideModel?> getGuide(String userId) async {
    final snap = await _db
        .collection('guides')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty
        ? GuideModel.fromFirestore(snap.docs.first)
        : null;
  }

  Stream<List<GuideModel>> getAllGuides() => _db
      .collection('guides')
      .where('isAvailable', isEqualTo: true)
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => GuideModel.fromFirestore(d)).toList(),
      );

  Future<void> updateGuide(GuideModel guide) =>
      _db.collection('guides').doc(guide.id).update(guide.toMap());

  // Booking Requests
  Future<void> requestGuide(BookingRequestModel request) =>
      _db.collection('bookings').doc(request.id).set(request.toMap());

  Stream<List<BookingRequestModel>> getMyBookingRequests(String touristId) =>
      _db
          .collection('bookings')
          .where('touristId', isEqualTo: touristId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => BookingRequestModel.fromFirestore(d))
                .toList(),
          );

  Stream<List<BookingRequestModel>> getGuideBookingRequests(String guideId) =>
      _db
          .collection('bookings')
          .where('guideId', isEqualTo: guideId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => BookingRequestModel.fromFirestore(d))
                .toList(),
          );

  Future<void> updateBookingStatus(String bookingId, String status) =>
      _db.collection('bookings').doc(bookingId).update({'status': status});

  Future<void> rateGuide({
    required String guideId,
    required String bookingId,
    required double rating,
  }) async {
    final batch = _db.batch();

    // Mark booking as rated
    batch.update(_db.collection('bookings').doc(bookingId), {
      'guideRating': rating,
      'ratedAt': Timestamp.now(),
    });

    // Recalculate guide average rating
    final guideRef = _db.collection('guides').doc(guideId);
    final guideDoc = await guideRef.get();
    if (guideDoc.exists) {
      final data = guideDoc.data()!;
      final oldCount = (data['reviewCount'] ?? 0) as int;
      final oldAvg = (data['rating'] ?? 0.0).toDouble();
      final newCount = oldCount + 1;
      final newAvg = ((oldAvg * oldCount) + rating) / newCount;
      batch.update(guideRef, {'rating': newAvg, 'reviewCount': newCount});
    }
    await batch.commit();
  }

  Stream<List<BookingRequestModel>> getMyBookingRequestsForTourist(
    String touristId,
  ) => _db
      .collection('bookings')
      .where('touristId', isEqualTo: touristId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => BookingRequestModel.fromFirestore(d)).toList(),
      );

  // User Profiles
  Future<void> saveUserProfile(UserProfileModel profile) =>
      _db.collection('users').doc(profile.userId).set(profile.toMap());

  Future<UserProfileModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? UserProfileModel.fromFirestore(doc) : null;
  }
}
