import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class PackagesRepository with AuditedWrite {
  PackagesRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('packages');

  Stream<List<SwimPackage>> watchAll() {
    return _col.snapshots().map((snap) => snap.docs.map((d) => SwimPackage.fromMap({...d.data(), 'id': d.id})).toList());
  }

  Future<String> create(SwimPackage package) async {
    final ref = package.id.isEmpty ? _col.doc() : _col.doc(package.id);
    await ref.set(tagged(package.toMap()..['id'] = ref.id));
    return ref.id;
  }

  Future<void> update(SwimPackage package) => _col.doc(package.id).set(tagged(package.toMap()));

  Future<void> delete(String id) => auditedDelete('packages', id);
}
