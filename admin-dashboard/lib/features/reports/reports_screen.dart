import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../data/repositories/reports_repository.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

/// One-shot load of everything the Reports & Analytics screen shows — same
/// re-fetch-on-load-or-refresh approach as the Dashboard's stats provider,
/// since none of these figures need to be live.
final _reportsDataProvider = FutureProvider<ReportsData>((ref) {
  return ref.watch(reportsRepositoryProvider).loadAll();
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(_reportsDataProvider);

    return AdminPageScaffold(
      title: 'Reports & Analytics',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => ref.invalidate(_reportsDataProvider),
        ),
      ],
      body: reportsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(40),
          child: Text('Failed to load reports: $err'),
        ),
        data: (data) => _ReportsBody(data: data),
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody({required this.data});
  final ReportsData data;

  @override
  Widget build(BuildContext context) {
    final attendance = data.attendance;
    final totalRevenue = data.revenueTrend.fold<double>(0, (sum, m) => sum + m.amount);
    final newMembers = data.memberGrowth.fold<int>(0, (sum, m) => sum + m.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              icon: Icons.event_available_outlined,
              label: 'Bookings (30d)',
              value: '${data.bookingsTrend.fold<int>(0, (sum, p) => sum + p.count)}',
            ),
            _StatCard(
              icon: Icons.fact_check_outlined,
              label: 'Attendance rate',
              value: '${attendance.rate.toStringAsFixed(0)}%',
            ),
            _StatCard(
              icon: Icons.payments_outlined,
              label: 'Revenue (6mo)',
              value: '${totalRevenue.toStringAsFixed(0)} SAR',
            ),
            _StatCard(
              icon: Icons.person_add_alt_1_outlined,
              label: 'New members (6mo)',
              value: '$newMembers',
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text('Bookings trend (last 30 days)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Count of bookings created per day.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _BookingsTrendCard(points: data.bookingsTrend),
        const SizedBox(height: 28),
        const Text('Attendance rate', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Completed vs. cancelled bookings (all time). Cancellations are treated as non-attendance — this app '
          "doesn't track a separate no-show flag, so it's an approximation.",
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _AttendanceCard(attendance: attendance),
        const SizedBox(height: 28),
        const Text('Popular classes & times', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Ranked by booking count over the last 30 days.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            SizedBox(width: context.isMobile ? double.infinity : 380, child: _PopularClassesCard(classes: data.popularClasses)),
            SizedBox(width: context.isMobile ? double.infinity : 320, child: _PopularTimesCard(times: data.popularTimes)),
          ],
        ),
        const SizedBox(height: 28),
        const Text('Revenue trend (last 6 months)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Sum of succeeded transactions, by month.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _RevenueTrendCard(points: data.revenueTrend),
        const SizedBox(height: 28),
        const Text('Member growth (last 6 months)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'New customer signups, by month.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _MemberGrowthCard(points: data.memberGrowth),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isMobile ? double.infinity : 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _BookingsTrendCard extends StatelessWidget {
  const _BookingsTrendCard({required this.points});
  final List<BookingsTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<int>(0, (m, p) => p.count > m ? p.count : m);

    return _Card(
      child: SizedBox(
        height: 200,
        child: maxValue <= 0
            ? const Center(child: Text('No bookings in this period.', style: TextStyle(color: Colors.black54)))
            : BarChart(
                BarChartData(
                  maxY: maxValue * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          // Sparse labels (every 5th day) — 30 daily bars are too
                          // narrow to label individually without overlap.
                          if (i < 0 || i >= points.length || i % 5 != 0) return const SizedBox.shrink();
                          final day = points[i].day;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = points[group.x.toInt()].day;
                        return BarTooltipItem(
                          '${day.month}/${day.day}: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: points[i].count.toDouble(),
                            color: AppColors.primary,
                            width: 6,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.attendance});
  final AttendanceStats attendance;

  @override
  Widget build(BuildContext context) {
    final total = attendance.completed + attendance.cancelled;
    final completedFraction = total == 0 ? 0.0 : attendance.completed / total;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${attendance.rate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(width: 12),
              const Text('completed', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: total == 0
                  ? Container(color: Colors.grey.shade200)
                  : Row(
                      children: [
                        Expanded(flex: (completedFraction * 1000).round().clamp(0, 1000), child: Container(color: AppColors.success)),
                        Expanded(
                          flex: ((1 - completedFraction) * 1000).round().clamp(0, 1000),
                          child: Container(color: AppColors.error),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: AppColors.success, label: 'Completed: ${attendance.completed}'),
              const SizedBox(width: 20),
              _LegendDot(color: AppColors.error, label: 'Cancelled: ${attendance.cancelled}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _PopularClassesCard extends StatelessWidget {
  const _PopularClassesCard({required this.classes});
  final List<ClassPopularity> classes;

  @override
  Widget build(BuildContext context) {
    final top = classes.take(8).toList();
    final maxCount = top.fold<int>(0, (m, c) => c.count > m ? c.count : m);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top classes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          if (top.isEmpty)
            const Text('No bookings in this period.', style: TextStyle(color: Colors.black54))
          else
            for (final entry in top)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(entry.title, overflow: TextOverflow.ellipsis)),
                        Text('${entry.count}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxCount == 0 ? 0 : entry.count / maxCount,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _PopularTimesCard extends StatelessWidget {
  const _PopularTimesCard({required this.times});
  final List<TimeSlotPopularity> times;

  @override
  Widget build(BuildContext context) {
    final top = times.take(8).toList();
    final maxCount = top.fold<int>(0, (m, t) => t.count > m ? t.count : m);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Popular times', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          if (top.isEmpty)
            const Text('No bookings in this period.', style: TextStyle(color: Colors.black54))
          else
            for (final entry in top)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(entry.label)),
                        Text('${entry.count}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxCount == 0 ? 0 : entry.count / maxCount,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _RevenueTrendCard extends StatelessWidget {
  const _RevenueTrendCard({required this.points});
  final List<RevenueMonth> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(0, (m, p) => p.amount > m ? p.amount : m);

    return _Card(
      child: SizedBox(
        height: 200,
        child: maxValue <= 0
            ? const Center(child: Text('No revenue in this period.', style: TextStyle(color: Colors.black54)))
            : BarChart(
                BarChartData(
                  maxY: maxValue * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= points.length) return const SizedBox.shrink();
                          final month = points[i].month;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_monthNames[month.month - 1], style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = points[group.x.toInt()].month;
                        return BarTooltipItem(
                          '${_monthNames[month.month - 1]}: ${rod.toY.toStringAsFixed(0)} SAR',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: points[i].amount,
                            color: AppColors.primary,
                            width: 22,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MemberGrowthCard extends StatelessWidget {
  const _MemberGrowthCard({required this.points});
  final List<MemberGrowthMonth> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<int>(0, (m, p) => p.count > m ? p.count : m);

    return _Card(
      child: SizedBox(
        height: 200,
        child: maxValue <= 0
            ? const Center(child: Text('No new members in this period.', style: TextStyle(color: Colors.black54)))
            : BarChart(
                BarChartData(
                  maxY: maxValue * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= points.length) return const SizedBox.shrink();
                          final month = points[i].month;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_monthNames[month.month - 1], style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = points[group.x.toInt()].month;
                        return BarTooltipItem(
                          '${_monthNames[month.month - 1]}: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: points[i].count.toDouble(),
                            color: AppColors.secondary,
                            width: 22,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
