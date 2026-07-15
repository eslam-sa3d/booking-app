import 'enums.dart';

class Payment {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String description;
  final String descriptionAr;
  final String? relatedPackageId;

  const Payment({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'SAR',
    required this.method,
    required this.status,
    required this.createdAt,
    required this.description,
    required this.descriptionAr,
    this.relatedPackageId,
  });

  String localizedDescription(bool isArabic) => isArabic ? descriptionAr : description;
}
