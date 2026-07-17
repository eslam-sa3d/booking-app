import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class PaymentMethodsRepository with AuditedWrite {
  PaymentMethodsRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('paymentMethods');

  Stream<List<PaymentMethodConfig>> watchAll() {
    return _col.orderBy('order').snapshots().map(
          (snap) => snap.docs.map((d) => PaymentMethodConfig.fromMap(d.data())).toList(),
        );
  }

  Future<String> create(PaymentMethodConfig method) async {
    final ref = method.id.isEmpty ? _col.doc() : _col.doc(method.id);
    await ref.set(tagged(method.toMap()..['id'] = ref.id));
    return ref.id;
  }

  Future<void> update(PaymentMethodConfig method) => _col.doc(method.id).set(tagged(method.toMap()));

  Future<void> delete(String id) => auditedDelete('paymentMethods', id);

  Future<void> reorder(List<PaymentMethodConfig> ordered) async {
    final batch = _db.batch();
    for (var i = 0; i < ordered.length; i++) {
      batch.update(_col.doc(ordered[i].id), tagged({'order': i}));
    }
    await batch.commit();
  }
}
