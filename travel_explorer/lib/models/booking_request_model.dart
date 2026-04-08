import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRequestModel {
  final String id;
  final String guideId;
  final String guideName;
  final String touristId;
  final String touristName;
  final String placeId;
  final String placeName;
  final DateTime requestedDate;
  final int hours;
  final String status; // 'pending', 'accepted', 'declined', 'completed'
  final String? message;
  final double? guideRating; // tourist's rating for the guide
  final DateTime createdAt;

  BookingRequestModel({
    required this.id,
    required this.guideId,
    required this.guideName,
    required this.touristId,
    required this.touristName,
    required this.placeId,
    required this.placeName,
    required this.requestedDate,
    required this.hours,
    this.status = 'pending',
    this.message,
    this.guideRating,
    required this.createdAt,
  });

  factory BookingRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingRequestModel(
      id: doc.id,
      guideId: data['guideId'] ?? '',
      guideName: data['guideName'] ?? '',
      touristId: data['touristId'] ?? '',
      touristName: data['touristName'] ?? '',
      placeId: data['placeId'] ?? '',
      placeName: data['placeName'] ?? '',
      requestedDate:
          (data['requestedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hours: data['hours'] ?? 1,
      status: data['status'] ?? 'pending',
      message: data['message'],
      guideRating: (data['guideRating'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'guideId': guideId,
    'guideName': guideName,
    'touristId': touristId,
    'touristName': touristName,
    'placeId': placeId,
    'placeName': placeName,
    'requestedDate': Timestamp.fromDate(requestedDate),
    'hours': hours,
    'status': status,
    'message': message,
    if (guideRating != null) 'guideRating': guideRating,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
