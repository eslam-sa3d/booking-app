import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/banner_repository.dart';

class FirebaseBannerRepository implements BannerRepository {
  FirebaseBannerRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<List<PromoBanner>> getActiveBanners() async {
    final snap = await _db.collection('banners').orderBy('order').get();
    return snap.docs.map((d) => PromoBanner.fromMap(d.data())).where((b) => b.isCurrentlyActive).toList();
  }

  @override
  Stream<List<PromoBanner>> watchActiveBanners() {
    return _db
        .collection('banners')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => PromoBanner.fromMap(d.data())).where((b) => b.isCurrentlyActive).toList());
  }
}
