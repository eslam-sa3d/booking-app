import 'firestore_codec.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String sessionId;
  final String classId;
  final String instructorId;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.sessionId,
    required this.classId,
    required this.instructorId,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'sessionId': sessionId,
        'classId': classId,
        'instructorId': instructorId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: map['id'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String? ?? '',
        sessionId: map['sessionId'] as String,
        classId: map['classId'] as String,
        instructorId: map['instructorId'] as String? ?? '',
        rating: (map['rating'] as num).toInt(),
        comment: map['comment'] as String? ?? '',
        createdAt: parseTimestamp(map['createdAt']),
      );
}
