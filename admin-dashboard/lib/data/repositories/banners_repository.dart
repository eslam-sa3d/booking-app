import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class BannersRepository {
  BannersRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('banners');

  Stream<List<PromoBanner>> watchAll() {
    return _col.orderBy('order').snapshots().map(
          (snap) => snap.docs.map((d) => PromoBanner.fromMap(d.data())).toList(),
        );
  }

  Future<String> create(PromoBanner banner) async {
    final ref = banner.id.isEmpty ? _col.doc() : _col.doc(banner.id);
    await ref.set(banner.toMap()..['id'] = ref.id);
    return ref.id;
  }

  Future<void> update(PromoBanner banner) => _col.doc(banner.id).set(banner.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> reorder(List<PromoBanner> orderedBanners) async {
    final batch = _db.batch();
    for (var i = 0; i < orderedBanners.length; i++) {
      batch.update(_col.doc(orderedBanners[i].id), {'order': i});
    }
    await batch.commit();
  }
}
