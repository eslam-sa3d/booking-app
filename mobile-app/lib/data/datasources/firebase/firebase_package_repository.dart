import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/package_repository.dart';

class FirebasePackageRepository implements PackageRepository {
  FirebasePackageRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<List<SwimPackage>> getPackages() async {
    final snap = await _db.collection('packages').get();
    return snap.docs.map((d) => SwimPackage.fromMap(d.data())).toList();
  }

  @override
  Future<List<UserPackage>> getUserPackages(String userId) async {
    final snap = await _db.collection('users').doc(userId).collection('packages').get();
    final packages = snap.docs.map((d) => UserPackage.fromMap(d.data())).toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return packages;
  }

  @override
  Future<UserPackage> purchasePackage({required String userId, required String packageId}) async {
    final packageSnap = await _db.collection('packages').doc(packageId).get();
    final package = SwimPackage.fromMap(packageSnap.data()!);
    final ref = _db.collection('users').doc(userId).collection('packages').doc();
    final userPackage = UserPackage(
      id: ref.id,
      userId: userId,
      packageId: packageId,
      purchasedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: package.validityDays)),
      sessionsRemaining: package.sessionCount,
    );
    await ref.set(userPackage.toMap());
    return userPackage;
  }

  @override
  Future<UserPackage> consumeSession(String userPackageId) async {
    final snap = await _db.collectionGroup('packages').where('id', isEqualTo: userPackageId).limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Package not found');
    final doc = snap.docs.first;
    final current = UserPackage.fromMap(doc.data());
    if (current.sessionsRemaining == null) return current;
    final updated = current.copyWith(sessionsRemaining: (current.sessionsRemaining! - 1).clamp(0, 999));
    await doc.reference.update({'sessionsRemaining': updated.sessionsRemaining});
    return updated;
  }
}
