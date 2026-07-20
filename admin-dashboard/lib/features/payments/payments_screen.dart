import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/widgets/page_scaffold.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  DateTimeRange? _range;
  Future<List<Payment>>? _rangedFuture;
  String? _classFilter;
  late Future<_RevenueReport> _reportFuture;

  String get _otherClassLabel => AppLocalizations.of(context)!.paymentsOtherClassLabel;

  @override
  void initState() {
    super.initState();
    _reportFuture = _loadReport();
  }

  Future<_RevenueReport> _loadReport() async {
    final repo = ref.read(transactionsRepositoryProvider);
    final now = DateTime.now();
    // Last 6 months, including the current (partial) one.
    final start = DateTime(now.year, now.month - 5, 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final payments = await repo.getTransactionsInRange(start, end);
    final succeeded = payments.where((p) => p.status == PaymentStatus.succeeded).toList();

    final byMonth = <String, double>{};
    final monthLabels = <String, String>{};
    for (var i = 0; i < 6; i++) {
      final m = DateTime(now.year, now.month - 5 + i, 1);
      final key = _monthKey(m);
      byMonth[key] = 0;
      monthLabels[key] = _monthLabel(m);
    }
    for (final p in succeeded) {
      final key = _monthKey(DateTime(p.createdAt.year, p.createdAt.month));
      if (byMonth.containsKey(key)) byMonth[key] = byMonth[key]! + p.amount;
    }

    final byClass = await repo.getRevenueByClass(payments);

    return _RevenueReport(monthlyRevenue: byMonth, monthLabels: monthLabels, revenueByClass: byClass);
  }

  static String _monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static String _monthLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked == null) return;
    final repo = ref.read(transactionsRepositoryProvider);
    final start = DateTime(picked.start.year, picked.start.month, picked.start.day);
    final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
    setState(() {
      _range = picked;
      _rangedFuture = repo.getTransactionsInRange(start, end);
    });
  }

  void _clearRange() {
    setState(() {
      _range = null;
      _rangedFuture = null;
    });
  }

  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transactionsStream = ref.watch(transactionsRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: l10n.paymentsTitle,
      body: StreamBuilder<List<Payment>>(
        stream: transactionsStream,
        builder: (context, snapshot) {
          final payments = snapshot.data ?? [];
          final succeeded = payments.where((p) => p.status == PaymentStatus.succeeded).toList();
          final totalRevenue = succeeded.fold<double>(0, (sum, p) => sum + p.amount);
          final refunded = payments.where((p) => p.status == PaymentStatus.refunded).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ReportStat(label: l10n.paymentsTotalRevenue, value: '${totalRevenue.toStringAsFixed(0)} EGP'),
                  _ReportStat(label: l10n.paymentsSuccessfulTransactions, value: '${succeeded.length}'),
                  _ReportStat(label: l10n.paymentsStatusRefunded, value: '$refunded'),
                ],
              ),
              const SizedBox(height: 28),
              Text(l10n.paymentsRevenueReportTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                l10n.paymentsRevenueReportDescription(_otherClassLabel),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              FutureBuilder<_RevenueReport>(
                future: _reportFuture,
                builder: (context, reportSnapshot) {
                  if (!reportSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _RevenueReportView(report: reportSnapshot.data!);
                },
              ),
              const SizedBox(height: 28),
              Text(l10n.paymentsFiltersTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              _buildFilterBar(),
              const SizedBox(height: 20),
              Text(l10n.paymentsTransactionsTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              _buildTransactionList(payments),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _pickRange,
          icon: const Icon(Icons.date_range_rounded, size: 18),
          label: Text(
            _range == null
                ? l10n.paymentsFilterByDateRange
                : l10n.paymentsDateRangeLabel(_fmtDate(_range!.start), _fmtDate(_range!.end)),
          ),
        ),
        if (_range != null)
          TextButton.icon(
            onPressed: _clearRange,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: Text(l10n.paymentsClearDateFilter),
          ),
        SizedBox(
          width: context.isMobile ? double.infinity : 240,
          child: StreamBuilder<List<SwimClass>>(
            stream: ref.watch(classesRepositoryProvider).watchClasses(),
            builder: (context, snapshot) {
              final classes = snapshot.data ?? [];
              final titles = classes.map((c) => c.title).toSet().toList()..sort();
              // Guard against a stale selection if the underlying class list changes.
              final value = titles.contains(_classFilter) || _classFilter == _otherClassLabel ? _classFilter : null;
              return DropdownButtonFormField<String?>(
                initialValue: value,
                decoration: InputDecoration(labelText: l10n.paymentsClassLabel, isDense: true),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.paymentsAllClasses)),
                  for (final title in titles) DropdownMenuItem(value: title, child: Text(title, overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: _otherClassLabel, child: Text(_otherClassLabel)),
                ],
                onChanged: (v) => setState(() => _classFilter = v),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(List<Payment> streamedPayments) {
    final future = _rangedFuture;
    if (future != null) {
      return FutureBuilder<List<Payment>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
          }
          return _classFilteredList(snapshot.data ?? []);
        },
      );
    }
    return _classFilteredList(streamedPayments);
  }

  Widget _classFilteredList(List<Payment> payments) {
    final classFilter = _classFilter;
    if (classFilter == null) {
      return _PaymentsList(payments: payments.take(100).toList());
    }
    // Class filter needs the best-effort booking -> session -> class join —
    // only run it for the (already date-filtered, capped) set being shown.
    final capped = payments.take(200).toList();
    return FutureBuilder<Map<String, String?>>(
      future: ref.read(transactionsRepositoryProvider).resolveClassTitles(capped),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
        }
        final titles = snapshot.data!;
        final filtered = capped.where((p) {
          final title = titles[p.id];
          if (classFilter == _otherClassLabel) return title == null;
          return title == classFilter;
        }).toList();
        return _PaymentsList(payments: filtered.take(100).toList());
      },
    );
  }
}

class _PaymentsList extends ConsumerWidget {
  const _PaymentsList({required this.payments});
  final List<Payment> payments;

  Future<void> _refund(BuildContext context, WidgetRef ref, Payment payment) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.paymentsRefundConfirmTitle),
        content: Text(
          l10n.paymentsRefundConfirmContent(payment.amount.toStringAsFixed(0), payment.currency, payment.description),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.paymentsRefund)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(transactionsRepositoryProvider).refund(payment.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (payments.isEmpty) {
      return Padding(padding: const EdgeInsets.all(24), child: Text(l10n.paymentsNoTransactions));
    }
    return Card(
      child: Column(
        children: [
          for (final payment in payments)
            ListTile(
              title: Text(payment.description),
              subtitle: Text('${payment.method} · ${payment.createdAt.toString().split(' ').first}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${payment.amount.toStringAsFixed(0)} ${payment.currency}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  _StatusChip(status: payment.status),
                  if (payment.status == PaymentStatus.succeeded)
                    IconButton(
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      tooltip: l10n.paymentsRefund,
                      onPressed: () => _refund(context, ref, payment),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RevenueReport {
  const _RevenueReport({required this.monthlyRevenue, required this.monthLabels, required this.revenueByClass});
  final Map<String, double> monthlyRevenue; // key: yyyy-mm, chronological order
  final Map<String, String> monthLabels; // key: yyyy-mm -> "Jan 2026"
  final Map<String, double> revenueByClass;
}

class _RevenueReportView extends StatelessWidget {
  const _RevenueReportView({required this.report});
  final _RevenueReport report;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        SizedBox(width: isMobile ? double.infinity : 460, child: _MonthlyRevenueCard(report: report)),
        SizedBox(width: isMobile ? double.infinity : 320, child: _ClassRevenueCard(report: report)),
      ],
    );
  }
}

class _MonthlyRevenueCard extends StatelessWidget {
  const _MonthlyRevenueCard({required this.report});
  final _RevenueReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keys = report.monthlyRevenue.keys.toList();
    final maxValue = report.monthlyRevenue.values.fold<double>(0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paymentsRevenueByMonth, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: maxValue <= 0
                ? Center(child: Text(l10n.paymentsNoRevenuePeriod, style: const TextStyle(color: Colors.black54)))
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
                              if (i < 0 || i >= keys.length) return const SizedBox.shrink();
                              final label = report.monthLabels[keys[i]] ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(label.split(' ').first, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < keys.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: report.monthlyRevenue[keys[i]]!,
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
        ],
      ),
    );
  }
}

class _ClassRevenueCard extends StatelessWidget {
  const _ClassRevenueCard({required this.report});
  final _RevenueReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = report.revenueByClass.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paymentsRevenueByClass, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(l10n.paymentsNoRevenuePeriod, style: const TextStyle(color: Colors.black54))
          else
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key, overflow: TextOverflow.ellipsis)),
                    Text('${entry.value.toStringAsFixed(0)} EGP', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isMobile ? double.infinity : 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final PaymentStatus status;

  Color get _color {
    switch (status) {
      case PaymentStatus.succeeded:
        return AppColors.success;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.secondary;
    }
  }

  String _label(AppLocalizations l10n) {
    switch (status) {
      case PaymentStatus.succeeded:
        return l10n.paymentsStatusSucceeded;
      case PaymentStatus.pending:
        return l10n.paymentsStatusPending;
      case PaymentStatus.failed:
        return l10n.paymentsStatusFailed;
      case PaymentStatus.refunded:
        return l10n.paymentsStatusRefunded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(_label(l10n), style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
