import '../models/models.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getPaymentHistory(String userId);

  Future<Payment> recordPayment(Payment payment);
}

class PaymentChargeResult {
  final bool success;
  final String? failureReason;
  final String? referenceId;
  const PaymentChargeResult({required this.success, this.failureReason, this.referenceId});
}

/// Abstraction over the actual payment gateway (Moyasar/HyperPay/Stripe).
/// [MockPaymentService] simulates a charge without any real gateway call —
/// swap the implementation when a gateway is chosen; the checkout UI and
/// [PaymentRepository] history flow don't need to change.
abstract class PaymentService {
  Future<PaymentChargeResult> charge({
    required double amount,
    required String currency,
    required PaymentMethod method,
  });
}
