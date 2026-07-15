import '../models/models.dart';

abstract class PackageRepository {
  Future<List<SwimPackage>> getPackages();

  Future<List<UserPackage>> getUserPackages(String userId);

  Future<UserPackage> purchasePackage({required String userId, required String packageId});

  /// Decrements remaining sessions on the given user package (no-op for
  /// unlimited packages). Returns the updated package.
  Future<UserPackage> consumeSession(String userPackageId);
}
