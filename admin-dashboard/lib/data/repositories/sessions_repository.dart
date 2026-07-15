import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class SessionsRepository with AuditedWrite {
  SessionsRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('sessions');

  Stream<List<SwimSession>> watchRange(DateTime start, DateTime end) {
    return _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs.map((d) => SwimSession.fromMap(d.data())).toList()
          ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime)));
  }

  Stream<List<SwimSession>> watchForClass(String classId) {
    return _col.where('classId', isEqualTo: classId).snapshots().map(
          (snap) => snap.docs.map((d) => SwimSession.fromMap(d.data())).toList()
            ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime)),
        );
  }

  /// Upcoming sessions taught by [instructorId] (today or later), ordered by date.
  Stream<List<SwimSession>> watchForInstructor(String instructorId) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _col
        .where('instructorId', isEqualTo: instructorId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .snapshots()
        .map((snap) => snap.docs.map((d) => SwimSession.fromMap(d.data())).toList()
          ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime)));
  }

  Future<String> create(SwimSession session) async {
    final ref = session.id.isEmpty ? _col.doc() : _col.doc(session.id);
    final withId = session.copyWith();
    final map = tagged(withId.toMap()..['id'] = ref.id);
    await ref.set(map);
    return ref.id;
  }

  /// Creates one session per matching weekday between [start] and [end]
  /// (inclusive) — the admin dashboard's bulk recurring-session tool.
  /// Dates in [blockedDates] (yyyy-mm-dd) are skipped.
  Future<int> createRecurring({
    required String classId,
    required String instructorId,
    required String branchId,
    required List<int> weekdays, // 1=Mon..7=Sun
    required int startMinutes,
    required int endMinutes,
    required int capacity,
    required DateTime start,
    required DateTime end,
    Set<String> blockedDates = const {},
  }) async {
    final batch = _db.batch();
    var count = 0;
    var day = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!day.isAfter(last)) {
      final key = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      if (weekdays.contains(day.weekday) && !blockedDates.contains(key)) {
        final ref = _col.doc();
        final session = SwimSession(
          id: ref.id,
          classId: classId,
          date: day,
          startMinutes: startMinutes,
          endMinutes: endMinutes,
          capacity: capacity,
          instructorId: instructorId,
          branchId: branchId,
        );
        batch.set(ref, tagged(session.toMap()));
        count++;
      }
      day = day.add(const Duration(days: 1));
    }
    await batch.commit();
    return count;
  }

  Future<void> update(SwimSession session) => _col.doc(session.id).set(tagged(session.toMap()));

  Future<void> delete(String id) => auditedDelete('sessions', id);
}
