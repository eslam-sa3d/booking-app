import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class BlockedDatesRepository with AuditedWrite {
  BlockedDatesRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('blockedDates');

  Stream<List<BlockedDate>> watchAll() {
    return _col.orderBy('date').snapshots().map(
          (snap) => snap.docs.map((d) => BlockedDate.fromMap(d.data())).toList(),
        );
  }

  Future<void> create({required DateTime date, String? branchId, required String reason}) async {
    final ref = _col.doc();
    await ref.set(tagged({
      'id': ref.id,
      'date': date,
      'branchId': branchId,
      'reason': reason,
      'createdBy': currentUid,
      'createdAt': DateTime.now(),
    }));
  }

  Future<void> delete(String id) => auditedDelete('blockedDates', id);
}
