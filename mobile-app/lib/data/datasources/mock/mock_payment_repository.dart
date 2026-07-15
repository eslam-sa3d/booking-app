import 'dart:math';

import '../../models/models.dart';
import '../../repositories/payment_repository.dart';
import 'mock_database.dart';

class MockPaymentRepository implements PaymentRepository {
  final _db = MockDatabase.instance;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<Payment>> getPaymentHistory(String userId) async {
    await _delay();
    return _db.payments.where((p) => p.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Payment> recordPayment(Payment payment) async {
    await _delay();
    final created = Payment(
      id: _db.nextId('pay'),
      userId: payment.userId,
      amount: payment.amount,
      currency: payment.currency,
      method: payment.method,
      status: payment.status,
      createdAt: DateTime.now(),
      description: payment.description,
      descriptionAr: payment.descriptionAr,
      relatedPackageId: payment.relatedPackageId,
    );
    _db.payments.add(created);
    return created;
  }

  @override
  Future<void> requestRefund(String transactionId, String reason) async {
    await _delay();
    final index = _db.payments.indexWhere((p) => p.id == transactionId);
    if (index == -1) throw Exception('Transaction not found');
    _db.payments[index] = _db.payments[index].copyWith(
      refundRequestStatus: RefundRequestStatus.pending,
      refundRequestedAt: DateTime.now(),
      refundRequestReason: reason,
    );
  }
}

/// Simulated payment gateway. Real integration (Moyasar/HyperPay/Stripe)
/// should implement [PaymentService] and be swapped in via the provider —
/// no UI changes required.
class MockPaymentService implements PaymentService {
  final _random = Random();

  @override
  Future<PaymentChargeResult> charge({
    required double amount,
    required String currency,
    required PaymentMethod method,
  }) async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 200));
    // 92% simulated success rate so the checkout failure state is reachable in demos.
    final success = _random.nextDouble() < 0.92;
    if (!success) {
      return const PaymentChargeResult(success: false, failureReason: 'Card declined by issuer.');
    }
    return PaymentChargeResult(success: true, referenceId: 'MOCK-${_random.nextInt(999999).toString().padLeft(6, '0')}');
  }
}
