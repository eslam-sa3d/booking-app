import '../models/models.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForClass(String classId);

  Future<Review> addReview(Review review);
}
