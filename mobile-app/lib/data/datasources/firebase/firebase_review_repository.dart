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
      sessionId: review.sessionId,
      classId: review.classId,
      instructorId: review.instructorId,
      rating: review.rating,
      comment: review.comment,
      createdAt: DateTime.now(),
    );
    await ref.set(created.toMap());

    final bookingSnap = await _db
        .collection('bookings')
        .where('sessionId', isEqualTo: review.sessionId)
        .where('userId', isEqualTo: review.userId)
        .limit(1)
        .get();
    if (bookingSnap.docs.isNotEmpty) {
      await bookingSnap.docs.first.reference.update({'reviewed': true});
    }
    return created;
  }
}
