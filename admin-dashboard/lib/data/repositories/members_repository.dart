import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class MembersRepository {
  MembersRepository(this._db);
  final FirebaseFirestore _db;

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

  Future<void> setSuspended(String uid, bool suspended) => _col.doc(uid).update({'suspended': suspended});
}
