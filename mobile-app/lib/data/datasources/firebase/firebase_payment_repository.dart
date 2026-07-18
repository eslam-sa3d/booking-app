import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/payment_repository.dart';

/// Records transaction history in Firestore. The actual charge itself is
/// still handled by [MockPaymentService] (see mock_payment_repository.dart)
/// since no real payment gateway has been chosen yet — see
/// backend/functions/src/payments/webhook.ts for the real-gateway TODO.
class FirebasePaymentRepository implements PaymentRepository {
  FirebasePaymentRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('transactions');

  @override
  Future<List<PaymentMethodConfig>> getActivePaymentMethods() async {
    final snap = await _db.collection('paymentMethods').orderBy('order').get();
    return snap.docs
        .map((d) => PaymentMethodConfig.fromMap({...d.data(), 'id': d.id}))
        .where((m) => m.isActive)
        .toList();
  }

  @override
  Future<List<Payment>> getPaymentHistory(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();
    final payments = snap.docs.map((d) => Payment.fromMap({...d.data(), 'id': d.id})).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return payments;
  }

  @override
  Future<Payment> recordPayment(Payment payment) async {
    final ref = _col.doc();
    final created = Payment(
      id: ref.id,
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
    await ref.set(created.toMap());
    return created;
  }

  @override
  Future<void> requestRefund(String transactionId, String reason) async {
    // Firestore security rules only allow a user to set these three fields
    // on their own transaction doc (and only to 'pending') — do not add
    // other fields to this update.
    await _col.doc(transactionId).update({
      'refundRequestStatus': RefundRequestStatus.pending.name,
      'refundRequestedAt': DateTime.now(),
      'refundRequestReason': reason,
    });
  }
}
