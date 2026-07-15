import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/class_repository.dart';

class FirebaseClassRepository implements ClassRepository {
  FirebaseClassRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<List<SwimClass>> getClasses({
    List<ClassCategory>? categories,
    String? branchId,
    String? query,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('classes');
    if (branchId != null) q = q.where('branchId', isEqualTo: branchId);
    final snap = await q.get();
    var classes = snap.docs.map((d) => SwimClass.fromMap(d.data())).toList();
    if (categories != null && categories.isNotEmpty) {
      classes = classes.where((c) => c.categories.any(categories.contains)).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final needle = query.trim().toLowerCase();
      classes = classes.where((c) => c.title.toLowerCase().contains(needle) || c.titleAr.contains(needle)).toList();
    }
    return classes;
  }

  @override
  Future<SwimClass> getClassById(String id) async {
    final snap = await _db.collection('classes').doc(id).get();
    return SwimClass.fromMap(snap.data()!);
  }

  @override
  Future<List<SwimSession>> getSessionsForClass(String classId) async {
    final snap = await _db.collection('sessions').where('classId', isEqualTo: classId).get();
    final sessions = snap.docs.map((d) => SwimSession.fromMap(d.data())).where((s) => !s.isPast).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return sessions;
  }

  @override
  Future<List<SwimSession>> getSessionsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _db
        .collection('sessions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();
    final sessions = snap.docs.map((d) => SwimSession.fromMap(d.data())).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return sessions;
  }

  @override
  Future<List<SwimSession>> getSessionsInRange(DateTime start, DateTime end) async {
    final snap = await _db
        .collection('sessions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
    final sessions = snap.docs.map((d) => SwimSession.fromMap(d.data())).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return sessions;
  }

  @override
  Future<SwimSession?> getSessionById(String sessionId) async {
    final snap = await _db.collection('sessions').doc(sessionId).get();
    if (!snap.exists) return null;
    return SwimSession.fromMap(snap.data()!);
  }

  @override
  Future<Instructor> getInstructor(String id) async {
    final snap = await _db.collection('instructors').doc(id).get();
    return Instructor.fromMap(snap.data()!);
  }

  @override
  Future<List<Instructor>> getInstructors() async {
    final snap = await _db.collection('instructors').get();
    return snap.docs.map((d) => Instructor.fromMap(d.data())).toList();
  }

  @override
  Future<Branch> getBranch(String id) async {
    final snap = await _db.collection('branches').doc(id).get();
    return Branch.fromMap(snap.data()!);
  }

  @override
  Future<List<Branch>> getBranches() async {
    final snap = await _db.collection('branches').get();
    return snap.docs.map((d) => Branch.fromMap(d.data())).toList();
  }
}
