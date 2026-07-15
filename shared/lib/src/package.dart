import 'enums.dart';
import 'firestore_codec.dart';

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

  SwimPackage copyWith({
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    PackageType? type,
    int? sessionCount,
    int? validityDays,
    double? price,
    String? currency,
    bool? isPopular,
  }) {
    return SwimPackage(
      id: id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      type: type ?? this.type,
      sessionCount: sessionCount ?? this.sessionCount,
      validityDays: validityDays ?? this.validityDays,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'descriptionAr': descriptionAr,
        'type': type.name,
        'sessionCount': sessionCount,
        'validityDays': validityDays,
        'price': price,
        'currency': currency,
        'isPopular': isPopular,
      };

  factory SwimPackage.fromMap(Map<String, dynamic> map) => SwimPackage(
        id: map['id'] as String,
        name: map['name'] as String,
        nameAr: map['nameAr'] as String,
        description: map['description'] as String? ?? '',
        descriptionAr: map['descriptionAr'] as String? ?? '',
        type: PackageType.fromName(map['type'] as String? ?? 'sessionPack'),
        sessionCount: (map['sessionCount'] as num?)?.toInt(),
        validityDays: (map['validityDays'] as num?)?.toInt() ?? 30,
        price: (map['price'] as num?)?.toDouble() ?? 0,
        currency: map['currency'] as String? ?? 'SAR',
        isPopular: map['isPopular'] as bool? ?? false,
      );
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'packageId': packageId,
        'purchasedAt': purchasedAt,
        'expiresAt': expiresAt,
        'sessionsRemaining': sessionsRemaining,
        'status': status.name,
      };

  factory UserPackage.fromMap(Map<String, dynamic> map) => UserPackage(
        id: map['id'] as String,
        userId: map['userId'] as String,
        packageId: map['packageId'] as String,
        purchasedAt: parseTimestamp(map['purchasedAt']),
        expiresAt: parseTimestamp(map['expiresAt']),
        sessionsRemaining: (map['sessionsRemaining'] as num?)?.toInt(),
        status: UserPackageStatus.fromName(map['status'] as String? ?? 'active'),
      );
}
