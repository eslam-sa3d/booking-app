import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class TransactionsRepository {
  TransactionsRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('transactions');

  Stream<List<Payment>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Payment.fromMap(d.data())).toList(),
        );
  }

  /// Manual entry (refund/adjustment) recorded by staff — real charges are
  /// written server-side by the (not-yet-implemented) payment webhook.
  Future<void> recordManualEntry(Payment payment) async {
    final ref = payment.id.isEmpty ? _col.doc() : _col.doc(payment.id);
    await ref.set(payment.toMap()..['id'] = ref.id);
  }

  Future<void> refund(String transactionId) => _col.doc(transactionId).update({'status': 'refunded'});
}
