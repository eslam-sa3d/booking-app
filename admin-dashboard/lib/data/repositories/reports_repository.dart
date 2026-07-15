import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

/// One day's worth of booking creations — a point on the Bookings trend
/// chart.
class BookingsTrendPoint {
  const BookingsTrendPoint({required this.day, required this.count});
  final DateTime day;
  final int count;
}

/// `completed` vs `cancelled` booking counts underlying the Attendance rate
/// stat.
class AttendanceStats {
  const AttendanceStats({required this.completed, required this.cancelled});
  final int completed;
  final int cancelled;

  /// completed / (completed + cancelled), as a percentage.
  ///
  /// APPROXIMATION: there's no tracked no-show flag distinct from a plain
  /// cancellation in this schema, so this treats every cancelled booking as
  /// "didn't attend" and every completed booking as "attended". It will
  /// undercount true attendance if a booking is ever cancelled for a reason
  /// unrelated to the member simply not showing up (e.g. a staff-initiated
  /// schedule change) — good enough for a directional metric, not exact.
  double get rate {
    final total = completed + cancelled;
    if (total == 0) return 0;
    return completed / total * 100;
  }
}

/// Booking count for one class, used for the "popular classes" ranking.
class ClassPopularity {
  const ClassPopularity({required this.classId, required this.title, required this.count});
  final String classId;
  final String title;
  final int count;
}

/// Booking count bucketed by hour-of-day (derived from
/// `SwimSession.startMinutes`) — e.g. hour 9 covers the 9:00-9:59 slot.
class TimeSlotPopularity {
  const TimeSlotPopularity({required this.hour, required this.count});
  final int hour;
  final int count;

  String get label {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:00 $period';
  }
}

/// Sum of succeeded transaction amounts for one calendar month — a point on
/// the Revenue trend chart.
class RevenueMonth {
  const RevenueMonth({required this.month, required this.amount});
  final DateTime month;
  final double amount;
}

/// Count of new customer signups for one calendar month — a point on the
/// Member growth chart.
class MemberGrowthMonth {
  const MemberGrowthMonth({required this.month, required this.count});
  final DateTime month;
  final int count;
}

/// Bundled snapshot of everything the Reports & Analytics screen shows.
/// Same one-shot-fetch philosophy as `DashboardStats` — the screen re-fetches
/// on load/refresh rather than staying subscribed, since none of these
/// figures need to update in real time.
class ReportsData {
  const ReportsData({
    required this.bookingsTrend,
    required this.attendance,
    required this.popularClasses,
    required this.popularTimes,
    required this.revenueTrend,
    required this.memberGrowth,
  });

  final List<BookingsTrendPoint> bookingsTrend;
  final AttendanceStats attendance;
  final List<ClassPopularity> popularClasses;
  final List<TimeSlotPopularity> popularTimes;
  final List<RevenueMonth> revenueTrend;
  final List<MemberGrowthMonth> memberGrowth;
}

/// Read-only aggregation queries backing the Reports & Analytics screen.
/// Firestore has no server-side aggregation beyond `.count()`/`.sum()` on a
/// single field, so anything that needs bucketing (by day, by hour, by
/// class) is fetched narrowed-down with a `createdAt` lower bound and then
/// aggregated client-side in Dart. This is a small/early-stage dataset, so
/// that's fine performance-wise.
///
/// No `AuditedWrite` mixin — this repository never writes.
class ReportsRepository {
  ReportsRepository(this._db);
  final FirebaseFirestore _db;

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);

  DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Count of `bookings` created per day over the last [days] days
  /// (default 30), oldest first.
  ///
  /// Single range filter on `createdAt` — no composite index needed,
  /// Firestore auto-indexes single-field range queries.
  Future<List<BookingsTrendPoint>> getBookingsTrend({int days = 30}) async {
    final today = _dayStart(DateTime.now());
    final cutoff = today.subtract(Duration(days: days - 1));
    final snap = await _db
        .collection('bookings')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .get();

    final counts = <DateTime, int>{
      for (var i = 0; i < days; i++) cutoff.add(Duration(days: i)): 0,
    };
    for (final doc in snap.docs) {
      final day = _dayStart(_toDate(doc.data()['createdAt']));
      if (counts.containsKey(day)) counts[day] = counts[day]! + 1;
    }
    final points = counts.entries.map((e) => BookingsTrendPoint(day: e.key, count: e.value)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return points;
  }

  /// Counts of `completed` vs `cancelled` bookings (all-time). Two separate
  /// equality-only `.count()` queries — each auto-indexed on a single
  /// field, so no composite index is needed.
  Future<AttendanceStats> getAttendanceStats() async {
    final results = await Future.wait([
      _db.collection('bookings').where('status', isEqualTo: 'completed').count().get(),
      _db.collection('bookings').where('status', isEqualTo: 'cancelled').count().get(),
    ]);
    return AttendanceStats(
      completed: results[0].count ?? 0,
      cancelled: results[1].count ?? 0,
    );
  }

  /// Top classes by booking count, and booking count by hour-of-day, over
  /// the last [days] days (default 30).
  ///
  /// Joins `bookings` -> `sessions` (via `sessionId`) -> `classes` (via
  /// `classId`). Rather than chunked `whereIn` lookups per booking, this
  /// fetches the (small, demo-scale) `sessions` and `classes` collections in
  /// full and joins in memory — the same "fetch the whole collection and
  /// build an id -> value map" pattern used for categories in
  /// classes_screen.dart.
  Future<({List<ClassPopularity> classes, List<TimeSlotPopularity> times})> getPopularClassesAndTimes({
    int days = 30,
  }) async {
    final cutoff = _dayStart(DateTime.now()).subtract(Duration(days: days - 1));
    final results = await Future.wait([
      _db.collection('bookings').where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff)).get(),
      _db.collection('sessions').get(),
      _db.collection('classes').get(),
    ]);
    final bookingsSnap = results[0];
    final sessionsById = {
      for (final d in results[1].docs) d.id: SwimSession.fromMap(d.data()),
    };
    final classTitleById = {
      for (final d in results[2].docs) d.id: (d.data()['title'] as String? ?? 'Untitled class'),
    };

    final classCounts = <String, int>{};
    final hourCounts = <int, int>{};
    for (final doc in bookingsSnap.docs) {
      final sessionId = doc.data()['sessionId'] as String?;
      final session = sessionId != null ? sessionsById[sessionId] : null;
      if (session == null) continue;
      classCounts[session.classId] = (classCounts[session.classId] ?? 0) + 1;
      final hour = session.startMinutes ~/ 60;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final classes = classCounts.entries
        .map((e) => ClassPopularity(classId: e.key, title: classTitleById[e.key] ?? 'Unknown class', count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final times = hourCounts.entries.map((e) => TimeSlotPopularity(hour: e.key, count: e.value)).toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return (classes: classes, times: times);
  }

  /// Sum of succeeded transaction amounts, grouped by month, for the last
  /// [months] months (default 6), oldest first.
  ///
  /// NOTE: this equality-on-`status` + range-on-`createdAt` query needs a
  /// composite index (status ASC, createdAt ASC) on `transactions` that
  /// isn't currently in firestore.indexes.json — same gap already flagged in
  /// dashboard_repository.dart's `getRevenueThisMonth`. Firestore will throw
  /// FAILED_PRECONDITION at runtime until that index is added (the error
  /// includes a direct link to create it).
  Future<List<RevenueMonth>> getRevenueTrend({int months = 6}) async {
    final now = DateTime.now();
    final firstMonth = DateTime(now.year, now.month - (months - 1), 1);
    final snap = await _db
        .collection('transactions')
        .where('status', isEqualTo: 'succeeded')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstMonth))
        .get();

    final totals = <DateTime, double>{
      for (var i = 0; i < months; i++) DateTime(firstMonth.year, firstMonth.month + i, 1): 0,
    };
    for (final doc in snap.docs) {
      final month = _monthStart(_toDate(doc.data()['createdAt']));
      if (totals.containsKey(month)) {
        totals[month] = totals[month]! + ((doc.data()['amount'] as num?)?.toDouble() ?? 0);
      }
    }
    final points = totals.entries.map((e) => RevenueMonth(month: e.key, amount: e.value)).toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    return points;
  }

  /// Count of new `users` with `role == 'customer'`, grouped by signup
  /// month, for the last [months] months (default 6), oldest first.
  ///
  /// NOTE: like [getRevenueTrend], this equality-on-`role` + range-on-
  /// `createdAt` query needs a composite index (role ASC, createdAt ASC) on
  /// `users` that isn't currently in firestore.indexes.json. Firestore will
  /// throw FAILED_PRECONDITION at runtime until that index is added.
  Future<List<MemberGrowthMonth>> getMemberGrowth({int months = 6}) async {
    final now = DateTime.now();
    final firstMonth = DateTime(now.year, now.month - (months - 1), 1);
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstMonth))
        .get();

    final counts = <DateTime, int>{
      for (var i = 0; i < months; i++) DateTime(firstMonth.year, firstMonth.month + i, 1): 0,
    };
    for (final doc in snap.docs) {
      final month = _monthStart(_toDate(doc.data()['createdAt']));
      if (counts.containsKey(month)) counts[month] = counts[month]! + 1;
    }
    final points = counts.entries.map((e) => MemberGrowthMonth(month: e.key, count: e.value)).toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    return points;
  }

  /// Fetches everything the Reports & Analytics screen needs in one shot.
  Future<ReportsData> loadAll() async {
    final results = await Future.wait<dynamic>([
      getBookingsTrend(),
      getAttendanceStats(),
      getPopularClassesAndTimes(),
      getRevenueTrend(),
      getMemberGrowth(),
    ]);
    final popular = results[2] as ({List<ClassPopularity> classes, List<TimeSlotPopularity> times});
    return ReportsData(
      bookingsTrend: results[0] as List<BookingsTrendPoint>,
      attendance: results[1] as AttendanceStats,
      popularClasses: popular.classes,
      popularTimes: popular.times,
      revenueTrend: results[3] as List<RevenueMonth>,
      memberGrowth: results[4] as List<MemberGrowthMonth>,
    );
  }
}
