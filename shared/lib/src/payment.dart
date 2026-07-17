import 'enums.dart';
import 'firestore_codec.dart';

class Payment {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String description;
  final String descriptionAr;
  final String? relatedPackageId;
  final String? relatedBookingId;
  final String? receiptNumber;
  final RefundRequestStatus? refundRequestStatus;
  final DateTime? refundRequestedAt;
  final String? refundRequestReason;
  final String? refundResolvedBy;

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
    this.relatedBookingId,
    this.receiptNumber,
    this.refundRequestStatus,
    this.refundRequestedAt,
    this.refundRequestReason,
    this.refundResolvedBy,
  });

  String localizedDescription(bool isArabic) => isArabic ? descriptionAr : description;

  Payment copyWith({
    RefundRequestStatus? refundRequestStatus,
    DateTime? refundRequestedAt,
    String? refundRequestReason,
    String? refundResolvedBy,
    PaymentStatus? status,
  }) =>
      Payment(
        id: id,
        userId: userId,
        amount: amount,
        currency: currency,
        method: method,
        status: status ?? this.status,
        createdAt: createdAt,
        description: description,
        descriptionAr: descriptionAr,
        relatedPackageId: relatedPackageId,
        relatedBookingId: relatedBookingId,
        receiptNumber: receiptNumber,
        refundRequestStatus: refundRequestStatus ?? this.refundRequestStatus,
        refundRequestedAt: refundRequestedAt ?? this.refundRequestedAt,
        refundRequestReason: refundRequestReason ?? this.refundRequestReason,
        refundResolvedBy: refundResolvedBy ?? this.refundResolvedBy,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'method': method,
        'status': status.name,
        'createdAt': createdAt,
        'description': description,
        'descriptionAr': descriptionAr,
        'relatedPackageId': relatedPackageId,
        'relatedBookingId': relatedBookingId,
        'receiptNumber': receiptNumber,
        'refundRequestStatus': refundRequestStatus?.name,
        'refundRequestedAt': refundRequestedAt,
        'refundRequestReason': refundRequestReason,
        'refundResolvedBy': refundResolvedBy,
      };

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        id: map['id'] as String,
        userId: map['userId'] as String,
        amount: (map['amount'] as num).toDouble(),
        currency: map['currency'] as String? ?? 'SAR',
        method: map['method'] as String? ?? 'creditCard',
        status: PaymentStatus.fromName(map['status'] as String? ?? 'pending'),
        createdAt: parseTimestamp(map['createdAt']),
        description: map['description'] as String? ?? '',
        descriptionAr: map['descriptionAr'] as String? ?? '',
        relatedPackageId: map['relatedPackageId'] as String?,
        relatedBookingId: map['relatedBookingId'] as String?,
        receiptNumber: map['receiptNumber'] as String?,
        refundRequestStatus: map['refundRequestStatus'] != null
            ? RefundRequestStatus.fromName(map['refundRequestStatus'] as String)
            : null,
        refundRequestedAt: parseTimestampOrNull(map['refundRequestedAt']),
        refundRequestReason: map['refundRequestReason'] as String?,
        refundResolvedBy: map['refundResolvedBy'] as String?,
      );
}
