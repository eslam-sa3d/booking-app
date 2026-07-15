import '../../models/models.dart';
import '../../repositories/review_repository.dart';
import 'mock_database.dart';

class MockReviewRepository implements ReviewRepository {
  final _db = MockDatabase.instance;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 350));

  @override
  Future<List<Review>> getReviewsForClass(String classId) async {
    await _delay();
    return _db.reviews.where((r) => r.classId == classId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Review> addReview(Review review) async {
    await _delay();
    final created = Review(
      id: _db.nextId('rv'),
      userId: review.userId,
      userName: review.userName,
      sessionId: review.sessionId,
      classId: review.classId,
      instructorId: review.instructorId,
      rating: review.rating,
      comment: review.comment,
      createdAt: DateTime.now(),
    );
    _db.reviews.add(created);

    final bookingIndex = _db.bookings.indexWhere((b) => b.sessionId == review.sessionId && b.userId == review.userId);
    if (bookingIndex != -1) {
      _db.bookings[bookingIndex] = _db.bookings[bookingIndex].copyWith(reviewed: true);
    }
    return created;
  }
}
