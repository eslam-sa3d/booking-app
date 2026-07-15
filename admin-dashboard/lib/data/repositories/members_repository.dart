import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class MembersRepository with AuditedWrite {
  MembersRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  Stream<List<AppUser>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => AppUser.fromMap(d.data())).toList(),
        );
  }

  Future<List<FamilyMember>> getFamilyMembers(String uid) async {
    final snap = await _col.doc(uid).collection('familyMembers').get();
    return snap.docs.map((d) => FamilyMember.fromMap(d.data())).toList();
  }

  Future<List<Booking>> getBookings(String uid) async {
    final snap = await _db.collection('bookings').where('userId', isEqualTo: uid).get();
    return snap.docs.map((d) => Booking.fromMap(d.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Payment>> getPayments(String uid) async {
    final snap = await _db.collection('transactions').where('userId', isEqualTo: uid).get();
    return snap.docs.map((d) => Payment.fromMap(d.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> setSuspended(String uid, bool suspended) =>
      _col.doc(uid).update(tagged({'suspended': suspended}));

  Future<void> updateProfile(String uid, {required String name, required String phone}) =>
      _col.doc(uid).update(tagged({'name': name, 'phone': phone}));

  Future<void> awardBadge(String uid, String familyMemberId, SwimBadge badge) async {
    final ref = _col.doc(uid).collection('familyMembers').doc(familyMemberId);
    final snap = await ref.get();
    final member = FamilyMember.fromMap(snap.data()!);
    await ref.update({'badges': [...member.badges, badge].map((b) => b.toMap()).toList()});
  }

  Future<void> addProgressNote(String uid, String familyMemberId, ProgressNote note) async {
    final ref = _col.doc(uid).collection('familyMembers').doc(familyMemberId);
    final snap = await ref.get();
    final member = FamilyMember.fromMap(snap.data()!);
    await ref.update({'progressNotes': [...member.progressNotes, note].map((n) => n.toMap()).toList()});
  }
}
