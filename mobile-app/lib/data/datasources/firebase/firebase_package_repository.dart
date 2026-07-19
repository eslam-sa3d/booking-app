import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/models.dart';
import '../../repositories/package_repository.dart';

class FirebasePackageRepository implements PackageRepository {
  FirebasePackageRepository(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  @override
  Future<List<SwimPackage>> getPackages() async {
    final snap = await _db.collection('packages').get();
    return snap.docs.map((d) => SwimPackage.fromMap({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<List<UserPackage>> getUserPackages(String userId) async {
    final snap = await _db.collection('users').doc(userId).collection('packages').get();
    final packages = snap.docs.map((d) => UserPackage.fromMap({...d.data(), 'id': d.id})).toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return packages;
  }

  // firestore.rules blocks direct client writes to both
  // `users/{uid}/packages` and `transactions` on purpose — package granting
  // and transaction recording both go through this callable so a client can
  // never self-grant session credits via a raw Firestore write.
  @override
  Future<PackagePurchaseOutcome> purchasePackage({
    required String userId,
    required SwimPackage package,
    required String method,
    required PaymentStatus status,
    String? failureReason,
  }) async {
    final callable = _functions.httpsCallable('purchasePackage');
    final result = await callable.call<Map<String, dynamic>>({
      'packageId': package.id,
      'method': method,
      'status': status.name,
      'failureReason': failureReason,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    final transaction = Payment.fromMap(Map<String, dynamic>.from(data['transaction'] as Map));
    final userPackageMap = data['userPackage'] as Map?;
    final userPackage = userPackageMap == null ? null : UserPackage.fromMap(Map<String, dynamic>.from(userPackageMap));
    return PackagePurchaseOutcome(transaction: transaction, userPackage: userPackage);
  }
}
