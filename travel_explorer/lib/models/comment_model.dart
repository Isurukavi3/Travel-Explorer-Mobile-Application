import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String placeId;
  final String authorId;
  final String authorName;
  final String text;
  final double rating;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      placeId: data['placeId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      text: data['text'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'placeId': placeId,
    'authorId': authorId,
    'authorName': authorName,
    'text': text,
    'rating': rating,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
