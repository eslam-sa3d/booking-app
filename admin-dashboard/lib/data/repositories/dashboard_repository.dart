import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

/// Bundled snapshot of the numbers shown on the Dashboard Overview screen.
/// Everything here is a one-shot read (not a live stream) — the dashboard
/// re-fetches on load/refresh rather than staying subscribed, since none of
/// these figures need to update in real time.
class DashboardStats {
  const DashboardStats({
    required this.todaysBookings,
    required this.revenueThisMonth,
    required this.upcomingSessions,
    required this.fullOrNearFullSessions,
    required this.expiringPackages,
  });

  final int todaysBookings;
  final double revenueThisMonth;
  final int upcomingSessions;
  final int fullOrNearFullSessions;
  final int expiringPackages;
}

class DashboardRepository {
  DashboardRepository(this._db);
  final FirebaseFirestore _db;

  /// Count of `bookings` created today — booking *activity*, not session
  /// date, since that's what's actionable for staff monitoring the desk.
  Future<int> getTodaysBookingsCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _db
        .collection('bookings')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Sum of `amount` across succeeded transactions created within the
  /// current calendar month.
  ///
  /// NOTE: this equality-on-`status` + range-on-`createdAt` query needs a
  /// composite index (status ASC, createdAt ASC) on `transactions` that
  /// isn't currently in firestore.indexes.json — the closest existing one
  /// there is keyed on `refundRequestStatus` + `createdAt`, which doesn't
  /// cover this. Firestore will throw FAILED_PRECONDITION at runtime until
  /// that index is added.
  Future<double> getRevenueThisMonth() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final snap = await _db
        .collection('transactions')
        .where('status', isEqualTo: 'succeeded')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();
    return snap.docs.fold<double>(
      0,
      (total, d) => total + ((d.data()['amount'] as num?)?.toDouble() ?? 0),
    );
  }

  /// Sessions starting today through the next [days] days (default 7),
  /// used both for the "upcoming sessions" count and to derive
  /// full/near-full sessions without a second query.
  Future<List<SwimSession>> getUpcomingSessions({int days = 7}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));
    final snap = await _db
        .collection('sessions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();
    return snap.docs.map((d) => SwimSession.fromMap(d.data())).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  /// Count of `users/*/packages` active packages expiring within the next
  /// [days] days (default 7). Reuses the existing `status` + `expiresAt`
  /// collectionGroup composite index already declared for `packages`.
  Future<int> getExpiringPackagesCount({int days = 7}) async {
    final horizon = DateTime.now().add(Duration(days: days));
    final snap = await _db
        .collectionGroup('packages')
        .where('status', isEqualTo: 'active')
        .where('expiresAt', isLessThanOrEqualTo: Timestamp.fromDate(horizon))
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<DashboardStats> loadStats() async {
    final results = await Future.wait<dynamic>([
      getTodaysBookingsCount(),
      getRevenueThisMonth(),
      getUpcomingSessions(),
      getExpiringPackagesCount(),
    ]);
    final todaysBookings = results[0] as int;
    final revenueThisMonth = results[1] as double;
    final upcoming = results[2] as List<SwimSession>;
    final expiringPackages = results[3] as int;
    final fullOrNearFull = upcoming.where((s) => s.capacity > 0 && s.bookedCount >= s.capacity * 0.8).length;

    return DashboardStats(
      todaysBookings: todaysBookings,
      revenueThisMonth: revenueThisMonth,
      upcomingSessions: upcoming.length,
      fullOrNearFullSessions: fullOrNearFull,
      expiringPackages: expiringPackages,
    );
  }
}
