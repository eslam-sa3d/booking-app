import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class SessionsRepository {
  SessionsRepository(this._db);
  final FirebaseFirestore _db;

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

  Future<String> create(SwimSession session) async {
    final ref = session.id.isEmpty ? _col.doc() : _col.doc(session.id);
    final withId = session.copyWith();
    final map = withId.toMap()..['id'] = ref.id;
    await ref.set(map);
    return ref.id;
  }

  /// Creates one session per matching weekday between [start] and [end]
  /// (inclusive) — the admin dashboard's bulk recurring-session tool.
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
  }) async {
    final batch = _db.batch();
    var count = 0;
    var day = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!day.isAfter(last)) {
      if (weekdays.contains(day.weekday)) {
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
        batch.set(ref, session.toMap());
        count++;
      }
      day = day.add(const Duration(days: 1));
    }
    await batch.commit();
    return count;
  }

  Future<void> update(SwimSession session) => _col.doc(session.id).set(session.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}
