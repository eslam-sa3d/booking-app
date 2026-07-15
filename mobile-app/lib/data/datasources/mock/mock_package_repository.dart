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
  Future<UserPackage> purchasePackage({required String userId, required String packageId}) async {
    await _delay();
    final package = MockSeedData.packages.firstWhere((p) => p.id == packageId);
    final userPackage = UserPackage(
      id: _db.nextId('up'),
      userId: userId,
      packageId: packageId,
      purchasedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: package.validityDays)),
      sessionsRemaining: package.sessionCount,
    );
    _db.userPackages.add(userPackage);
    return userPackage;
  }

  @override
  Future<UserPackage> consumeSession(String userPackageId) async {
    await _delay();
    final index = _db.userPackages.indexWhere((p) => p.id == userPackageId);
    if (index == -1) throw Exception('Package not found');
    final current = _db.userPackages[index];
    if (current.sessionsRemaining == null) return current;
    final updated = current.copyWith(sessionsRemaining: (current.sessionsRemaining! - 1).clamp(0, 999));
    _db.userPackages[index] = updated;
    return updated;
  }
}
