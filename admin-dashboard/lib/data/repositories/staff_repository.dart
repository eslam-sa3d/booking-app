import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared/shared.dart';

class StaffRepository {
  StaffRepository(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<List<AppUser>> watchStaffAndAdmins() {
    return _db
        .collection('users')
        .where('role', whereIn: ['staff', 'admin'])
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppUser.fromMap(d.data())).toList());
  }

  /// Admin-only — enforced server-side by the callable itself (checks the
  /// caller's own custom claim), not just by hiding the button client-side.
  Future<void> assignRole({required String targetUid, required String role}) async {
    final callable = _functions.httpsCallable('assignStaffRole');
    await callable.call({'targetUid': targetUid, 'role': role});
  }
}
