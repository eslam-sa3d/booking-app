import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class BannersRepository with AuditedWrite {
  BannersRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('banners');

  Stream<List<PromoBanner>> watchAll() {
    return _col.orderBy('order').snapshots().map(
          (snap) => snap.docs.map((d) => PromoBanner.fromMap({...d.data(), 'id': d.id})).toList(),
        );
  }

  Future<String> create(PromoBanner banner) async {
    final ref = banner.id.isEmpty ? _col.doc() : _col.doc(banner.id);
    await ref.set(tagged(banner.toMap()..['id'] = ref.id));
    return ref.id;
  }

  Future<void> update(PromoBanner banner) => _col.doc(banner.id).set(tagged(banner.toMap()));

  Future<void> delete(String id) => auditedDelete('banners', id);

  Future<void> reorder(List<PromoBanner> orderedBanners) async {
    final batch = _db.batch();
    for (var i = 0; i < orderedBanners.length; i++) {
      batch.update(_col.doc(orderedBanners[i].id), tagged({'order': i}));
    }
    await batch.commit();
  }
}
