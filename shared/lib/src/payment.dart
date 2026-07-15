import 'enums.dart';
import 'firestore_codec.dart';

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'method': method.name,
        'status': status.name,
        'createdAt': createdAt,
        'description': description,
        'descriptionAr': descriptionAr,
        'relatedPackageId': relatedPackageId,
      };

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        id: map['id'] as String,
        userId: map['userId'] as String,
        amount: (map['amount'] as num).toDouble(),
        currency: map['currency'] as String? ?? 'SAR',
        method: PaymentMethod.fromName(map['method'] as String? ?? 'creditCard'),
        status: PaymentStatus.fromName(map['status'] as String? ?? 'pending'),
        createdAt: parseTimestamp(map['createdAt']),
        description: map['description'] as String? ?? '',
        descriptionAr: map['descriptionAr'] as String? ?? '',
        relatedPackageId: map['relatedPackageId'] as String?,
      );
}
