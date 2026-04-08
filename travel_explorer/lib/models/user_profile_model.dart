import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String userId;
  final String name;
  final String? profileImageUrl;
  final String? phone;
  final String? email;
  final String? website;
  final List<String> interests;
  final DateTime createdAt;

  UserProfileModel({
    required this.userId,
    required this.name,
    this.profileImageUrl,
    this.phone,
    this.email,
    this.website,
    this.interests = const [],
    required this.createdAt,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      userId: doc.id,
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      phone: data['phone'],
      email: data['email'],
      website: data['website'],
      interests: List<String>.from(data['interests'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'profileImageUrl': profileImageUrl,
    'phone': phone,
    'email': email,
    'website': website,
    'interests': interests,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
