import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class ClassesRepository with AuditedWrite {
  ClassesRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('classes');

  Stream<List<SwimClass>> watchClasses() {
    return _col.orderBy('title').snapshots().map(
          (snap) => snap.docs.map((d) => SwimClass.fromMap({...d.data(), 'id': d.id})).toList(),
        );
  }

  Future<SwimClass?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return SwimClass.fromMap({...doc.data()!, 'id': doc.id});
  }

  Future<String> create(SwimClass swimClass) async {
    final ref = swimClass.id.isEmpty ? _col.doc() : _col.doc(swimClass.id);
    await ref.set(tagged(swimClass.copyWith().toMap()..['id'] = ref.id));
    return ref.id;
  }

  Future<void> update(SwimClass swimClass) => _col.doc(swimClass.id).set(tagged(swimClass.toMap()));

  Future<void> delete(String id) => auditedDelete('classes', id);
}
