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
}
