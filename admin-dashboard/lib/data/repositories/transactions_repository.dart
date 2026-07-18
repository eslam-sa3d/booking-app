import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class TransactionsRepository with AuditedWrite {
  TransactionsRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('transactions');

  Stream<List<Payment>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Payment.fromMap({...d.data(), 'id': d.id})).toList(),
        );
  }

  /// Pending customer-initiated refund requests — Requests Management's
  /// refund queue (admin-only; Payments & Reports is excluded from staff).
  Stream<List<Payment>> watchPendingRefundRequests() {
    return _col
        .where('refundRequestStatus', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Payment.fromMap({...d.data(), 'id': d.id})).toList());
  }

  /// Manual entry (refund/adjustment) recorded by staff — real charges are
  /// written server-side by the (not-yet-implemented) payment webhook.
  Future<void> recordManualEntry(Payment payment) async {
    final ref = payment.id.isEmpty ? _col.doc() : _col.doc(payment.id);
    await ref.set(tagged(payment.toMap()..['id'] = ref.id));
  }

  Future<void> refund(String transactionId) =>
      _col.doc(transactionId).update(tagged({'status': 'refunded'}));

  /// Approves a pending refund request: marks the transaction refunded and
  /// resolves the request. Denying leaves the transaction status untouched.
  Future<void> resolveRefundRequest(String transactionId, {required bool approve}) => _col.doc(transactionId).update(
        tagged({
          'refundRequestStatus': approve ? 'approved' : 'denied',
          'refundResolvedBy': currentUid,
          if (approve) 'status': 'refunded',
        }),
      );

  /// Transactions created within [start, end] (inclusive), newest first.
  /// Backs the Payments & Reports date-range filter and revenue report —
  /// a one-shot fetch rather than a stream since reports are point-in-time.
  Future<List<Payment>> getTransactionsInRange(DateTime start, DateTime end) async {
    final snap = await _col
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Payment.fromMap({...d.data(), 'id': d.id})).toList();
  }

  /// Best-effort join from each transaction to the class it relates to, via
  /// relatedBookingId -> bookings/{id}.sessionId -> sessions/{id}.classId ->
  /// classes/{id}.title. Transactions with no relatedBookingId (expected for
  /// most transactions predating that field) or a broken link resolve to
  /// null — callers should bucket those as "Other / Unlinked".
  Future<Map<String, String?>> resolveClassTitles(List<Payment> payments) async {
    final bookingIds = payments.map((p) => p.relatedBookingId).whereType<String>().toSet();
    final bookingToSession = <String, String?>{};
    await Future.wait(bookingIds.map((id) async {
      final doc = await _db.collection('bookings').doc(id).get();
      bookingToSession[id] = doc.data()?['sessionId'] as String?;
    }));

    final sessionIds = bookingToSession.values.whereType<String>().toSet();
    final sessionToClass = <String, String?>{};
    await Future.wait(sessionIds.map((id) async {
      final doc = await _db.collection('sessions').doc(id).get();
      sessionToClass[id] = doc.data()?['classId'] as String?;
    }));

    final classIds = sessionToClass.values.whereType<String>().toSet();
    final classToTitle = <String, String>{};
    await Future.wait(classIds.map((id) async {
      final doc = await _db.collection('classes').doc(id).get();
      final title = doc.data()?['title'] as String?;
      if (title != null) classToTitle[id] = title;
    }));

    return {
      for (final p in payments)
        p.id: (() {
          final bookingId = p.relatedBookingId;
          final sessionId = bookingId != null ? bookingToSession[bookingId] : null;
          final classId = sessionId != null ? sessionToClass[sessionId] : null;
          return classId != null ? classToTitle[classId] : null;
        })(),
    };
  }

  /// Total revenue (succeeded transactions only) in [payments], grouped by
  /// class title — see [resolveClassTitles]. Unresolved transactions are
  /// grouped under "Other / Unlinked".
  Future<Map<String, double>> getRevenueByClass(List<Payment> payments) async {
    const otherLabel = 'Other / Unlinked';
    final succeeded = payments.where((p) => p.status == PaymentStatus.succeeded).toList();
    final titles = await resolveClassTitles(succeeded);
    final result = <String, double>{};
    for (final p in succeeded) {
      final label = titles[p.id] ?? otherLabel;
      result[label] = (result[label] ?? 0) + p.amount;
    }
    return result;
  }
}
