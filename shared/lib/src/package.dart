import 'enums.dart';

class SwimPackage {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final PackageType type;
  final int? sessionCount; // null = unlimited
  final int validityDays;
  final double price;
  final String currency;
  final bool isPopular;

  const SwimPackage({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.type,
    this.sessionCount,
    required this.validityDays,
    required this.price,
    this.currency = 'SAR',
    this.isPopular = false,
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : name;
  String localizedDescription(bool isArabic) => isArabic ? descriptionAr : description;
}

class UserPackage {
  final String id;
  final String userId;
  final String packageId;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final int? sessionsRemaining; // null = unlimited
  final UserPackageStatus status;

  const UserPackage({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.purchasedAt,
    required this.expiresAt,
    this.sessionsRemaining,
    this.status = UserPackageStatus.active,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get daysLeft => expiresAt.difference(DateTime.now()).inDays.clamp(0, 100000);

  UserPackage copyWith({int? sessionsRemaining, UserPackageStatus? status}) {
    return UserPackage(
      id: id,
      userId: userId,
      packageId: packageId,
      purchasedAt: purchasedAt,
      expiresAt: expiresAt,
      sessionsRemaining: sessionsRemaining ?? this.sessionsRemaining,
      status: status ?? this.status,
    );
  }
}
