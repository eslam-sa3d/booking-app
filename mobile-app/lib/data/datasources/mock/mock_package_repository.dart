import '../../models/models.dart';
import '../../repositories/package_repository.dart';
import 'mock_database.dart';
import 'mock_seed_data.dart';

class MockPackageRepository implements PackageRepository {
  final _db = MockDatabase.instance;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<SwimPackage>> getPackages() async {
    await _delay();
    return MockSeedData.packages;
  }

  @override
  Future<List<UserPackage>> getUserPackages(String userId) async {
    await _delay();
    return _db.userPackages.where((p) => p.userId == userId).toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
  }

  @override
  Future<PackagePurchaseOutcome> purchasePackage({
    required String userId,
    required SwimPackage package,
    required String method,
    required PaymentStatus status,
    String? failureReason,
  }) async {
    await _delay();
    final transaction = Payment(
      id: _db.nextId('pay'),
      userId: userId,
      amount: package.price,
      currency: package.currency,
      method: method,
      status: status,
      createdAt: DateTime.now(),
      description: '${package.name} purchase',
      descriptionAr: 'شراء ${package.nameAr}',
      relatedPackageId: package.id,
    );
    _db.payments.add(transaction);

    if (status != PaymentStatus.succeeded) {
      return PackagePurchaseOutcome(transaction: transaction);
    }

    final userPackage = UserPackage(
      id: _db.nextId('up'),
      userId: userId,
      packageId: package.id,
      purchasedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: package.validityDays)),
      sessionsRemaining: package.sessionCount,
    );
    _db.userPackages.add(userPackage);
    return PackagePurchaseOutcome(transaction: transaction, userPackage: userPackage);
  }
}
