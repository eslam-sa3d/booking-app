import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class InstructorsRepository with AuditedWrite {
  InstructorsRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('instructors');

  Stream<List<Instructor>> watchAll() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Instructor.fromMap(d.data())).toList(),
        );
  }

  Future<String> create(Instructor instructor) async {
    final ref = instructor.id.isEmpty ? _col.doc() : _col.doc(instructor.id);
    await ref.set(tagged(instructor.toMap()..['id'] = ref.id));
    return ref.id;
  }

  Future<void> update(Instructor instructor) => _col.doc(instructor.id).set(tagged(instructor.toMap()));

  Future<void> delete(String id) => auditedDelete('instructors', id);

  /// Computes a real average rating (and review count) for [instructorId]
  /// from the `reviews` collection, at read time — does not touch the
  /// static [Instructor.rating] default and is not written back.
  Future<InstructorRating> getComputedRating(String instructorId) async {
    final snap = await _db.collection('reviews').where('instructorId', isEqualTo: instructorId).get();
    if (snap.docs.isEmpty) return const InstructorRating(average: null, count: 0);
    final ratings = snap.docs.map((d) => (d.data()['rating'] as num).toDouble()).toList();
    final average = ratings.reduce((a, b) => a + b) / ratings.length;
    return InstructorRating(average: average, count: ratings.length);
  }
}

/// A computed rating summary for an instructor, derived from `reviews`.
/// [average] is null when there are no reviews yet.
class InstructorRating {
  const InstructorRating({required this.average, required this.count});
  final double? average;
  final int count;

  String get display => average == null ? 'No ratings yet' : '${average!.toStringAsFixed(1)} ($count)';
}
