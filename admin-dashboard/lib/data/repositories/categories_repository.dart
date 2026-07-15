import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class CategoriesRepository with AuditedWrite {
  CategoriesRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('categories');

  Stream<List<Category>> watchAll() {
    return _col.orderBy('order').snapshots().map(
          (snap) => snap.docs.map((d) => Category.fromMap(d.data())).toList(),
        );
  }

  Future<String> create(Category category) async {
    final ref = category.id.isEmpty ? _col.doc() : _col.doc(category.id);
    await ref.set(tagged(category.toMap()..['id'] = ref.id));
    return ref.id;
  }

  Future<void> update(Category category) => _col.doc(category.id).set(tagged(category.toMap()));

  Future<void> delete(String id) => auditedDelete('categories', id);

  Future<void> reorder(List<Category> ordered) async {
    final batch = _db.batch();
    for (var i = 0; i < ordered.length; i++) {
      batch.update(_col.doc(ordered[i].id), tagged({'order': i}));
    }
    await batch.commit();
  }
}
