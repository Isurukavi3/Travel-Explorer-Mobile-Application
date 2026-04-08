import 'package:cloud_firestore/cloud_firestore.dart';

class GuideModel {
  final String id;
  final String userId;
  final String name;
  final String bio;
  final String expertise; // e.g., "Historical sites, Nature trails"
  final double hourlyRate;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;

  GuideModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.bio,
    required this.expertise,
    required this.hourlyRate,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory GuideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GuideModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      expertise: data['expertise'] ?? '',
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'bio': bio,
    'expertise': expertise,
    'hourlyRate': hourlyRate,
    'rating': rating,
    'reviewCount': reviewCount,
    'isAvailable': isAvailable,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
