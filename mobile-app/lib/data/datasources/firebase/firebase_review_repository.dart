import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/review_repository.dart';

class FirebaseReviewRepository implements ReviewRepository {
  FirebaseReviewRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('reviews');

  @override
  Future<List<Review>> getReviewsForClass(String classId) async {
    final snap = await _col.where('classId', isEqualTo: classId).get();
    final reviews = snap.docs.map((d) => Review.fromMap({...d.data(), 'id': d.id})).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  @override
  Future<Review> addReview(Review review) async {
    final ref = _col.doc();
    final created = Review(
      id: ref.id,
      userId: review.userId,
      userName: review.userName,
      bookingId: review.bookingId,
      sessionId: review.sessionId,
      classId: review.classId,
      instructorId: review.instructorId,
      rating: review.rating,
      comment: review.comment,
      createdAt: DateTime.now(),
    );
    // firestore.rules requires this bookingId to reference the caller's own
    // completed booking for sessionId, so the write fails outright if the
    // caller never actually attended.
    await ref.set(created.toMap());
    await _db.collection('bookings').doc(review.bookingId).update({'reviewed': true});
    return created;
  }
}
