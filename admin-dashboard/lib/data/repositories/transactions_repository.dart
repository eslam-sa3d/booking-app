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

  // Bounded so the Payments screen doesn't stream every transaction ever
  // (and re-fire on every unrelated write anywhere in the app) as
  // transaction history grows — until this becomes real server-side
  // pagination, only the most recent 500 are live-watched.
  static const _watchLimit = 500;

  Stream<List<Payment>> watchAll() {
    return _col.orderBy('createdAt', descending: true).limit(_watchLimit).snapshots().map(
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

  /// Refunds a succeeded transaction. Reads-then-writes inside a
  /// transaction so two staff clicking "refund" on the same transaction
  /// concurrently can't both succeed — the second read sees the first
  /// write's result and throws [AlreadyRefundedException].
  Future<void> refund(String transactionId) {
    final ref = _col.doc(transactionId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.data()?['status'] == 'refunded') {
        throw const AlreadyRefundedException();
      }
      tx.update(ref, tagged({'status': 'refunded'}));
    });
  }

  /// Approves or denies a pending refund request: marks the transaction
  /// refunded (if approved) and resolves the request. Denying leaves the
  /// transaction status untouched. Reads-then-writes inside a transaction
  /// so two staff resolving the same request concurrently can't both
  /// succeed — the loser sees the request is no longer 'pending' and
  /// throws [RefundRequestNotPendingException] instead of double-resolving it.
  Future<void> resolveRefundRequest(String transactionId, {required bool approve}) {
    final ref = _col.doc(transactionId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.data()?['refundRequestStatus'] != 'pending') {
        throw const RefundRequestNotPendingException();
      }
      tx.update(
        ref,
        tagged({
          'refundRequestStatus': approve ? 'approved' : 'denied',
          'refundResolvedBy': currentUid,
          if (approve) 'status': 'refunded',
        }),
      );
    });
  }

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

class AlreadyRefundedException implements Exception {
  const AlreadyRefundedException();
  @override
  String toString() => 'This transaction has already been refunded.';
}

class RefundRequestNotPendingException implements Exception {
  const RefundRequestNotPendingException();
  @override
  String toString() => 'This refund request has already been resolved by someone else.';
}
