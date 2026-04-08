import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'popular' or 'hidden'
  final List<String> tags; // e.g., ['Beach', 'Restaurant', 'Museum']
  final double latitude;
  final double longitude;
  final String address;
  final List<String> imageUrls;
  final String authorId;
  final String authorName;
  final double averageRating;
  final int ratingCount;
  final int commentCount;
  final DateTime createdAt;

  PlaceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.tags = const [],
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.imageUrls,
    required this.authorId,
    required this.authorName,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.commentCount = 0,
    required this.createdAt,
  });

  factory PlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaceModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'popular',
      tags: List<String>.from(data['tags'] ?? []),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'tags': tags,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'imageUrls': imageUrls,
    'authorId': authorId,
    'authorName': authorName,
    'averageRating': averageRating,
    'ratingCount': ratingCount,
    'commentCount': commentCount,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
