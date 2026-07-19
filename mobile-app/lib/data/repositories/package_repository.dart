import '../models/models.dart';

class PackagePurchaseOutcome {
  const PackagePurchaseOutcome({required this.transaction, this.userPackage});
  final Payment transaction;
  final UserPackage? userPackage;
  bool get success => userPackage != null;
}

abstract class PackageRepository {
  Future<List<SwimPackage>> getPackages();

  Future<List<UserPackage>> getUserPackages(String userId);

  /// Records the transaction and, if [status] is [PaymentStatus.succeeded],
  /// grants the package — both as one atomic server-side operation (the
  /// `purchasePackage` Cloud Function), since firestore.rules blocks direct
  /// client writes to both `users/{uid}/packages` and `transactions`. A
  /// client can never self-grant session credits via a raw Firestore write.
  Future<PackagePurchaseOutcome> purchasePackage({
    required String userId,
    required SwimPackage package,
    required String method,
    required PaymentStatus status,
    String? failureReason,
  });
}
