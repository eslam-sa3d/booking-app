import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/responsive_dialog.dart';
import 'recurring_session_dialog.dart';
import 'session_form_dialog.dart';

final _selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
final _focusedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static Future<bool> _confirm(BuildContext context, {required String title, required String content}) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDay = ref.watch(_selectedDayProvider);
    final focusedMonth = ref.watch(_focusedMonthProvider);
    final classesStream = ref.watch(classesRepositoryProvider).watchClasses();
    final monthStart = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final monthEnd = DateTime(focusedMonth.year, focusedMonth.month + 1, 0, 23, 59);
    final sessionsStream = ref.watch(sessionsRepositoryProvider).watchRange(monthStart, monthEnd);

    return StreamBuilder<List<SwimClass>>(
      stream: classesStream,
      builder: (context, classSnap) {
        final classes = classSnap.data ?? [];
        final classesById = {for (final c in classes) c.id: c};

        final blockedDatesStream = ref.watch(blockedDatesRepositoryProvider).watchAll();

        return AdminPageScaffold(
          title: l10n.calendarTitle,
          actions: [
            OutlinedButton.icon(
              onPressed: () => showDialog(context: context, builder: (_) => const _BlockedDatesDialog()),
              icon: const Icon(Icons.block),
              label: Text(l10n.calendarManageBlockedDates),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: classes.isEmpty ? null : () => showRecurringSessionDialog(context, ref, classes: classes),
              icon: const Icon(Icons.repeat_rounded),
              label: Text(l10n.calendarBulkCreateRecurring),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: classes.isEmpty ? null : () => showSessionFormDialog(context, ref, date: selectedDay, classes: classes),
              icon: const Icon(Icons.add),
              label: Text(l10n.calendarAddSession),
            ),
          ],
          body: StreamBuilder<List<SwimSession>>(
            stream: sessionsStream,
            builder: (context, sessionSnap) {
              final sessions = sessionSnap.data ?? [];
              final eventCounts = <DateTime, int>{};
              for (final s in sessions) {
                final key = DateTime(s.date.year, s.date.month, s.date.day);
                eventCounts[key] = (eventCounts[key] ?? 0) + 1;
              }
              final daySessions = sessions.where((s) => isSameDay(s.date, selectedDay)).toList()
                ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

              return StreamBuilder<List<BlockedDate>>(
                stream: blockedDatesStream,
                builder: (context, blockedSnap) {
                  final blockedDays = <DateTime>{
                    for (final bd in blockedSnap.data ?? const <BlockedDate>[])
                      DateTime(bd.date.year, bd.date.month, bd.date.day),
                  };
                  final isSelectedDayBlocked = blockedDays.contains(DateTime(selectedDay.year, selectedDay.month, selectedDay.day));

                  final calendarCard = Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: focusedMonth,
                        selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                        holidayPredicate: (day) => blockedDays.contains(DateTime(day.year, day.month, day.day)),
                        eventLoader: (day) {
                          final key = DateTime(day.year, day.month, day.day);
                          final count = eventCounts[key] ?? 0;
                          return List.filled(count > 3 ? 3 : count, 0);
                        },
                        onDaySelected: (selected, focused) {
                          ref.read(_selectedDayProvider.notifier).state = DateTime(selected.year, selected.month, selected.day);
                          ref.read(_focusedMonthProvider.notifier).state = DateTime(focused.year, focused.month, 1);
                        },
                        onPageChanged: (focused) => ref.read(_focusedMonthProvider.notifier).state = DateTime(focused.year, focused.month, 1),
                        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          todayDecoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                          markerDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          holidayTextStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
                          holidayDecoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ),
                  );

                  final sessionListCard = Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          if (isSelectedDayBlocked) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.block, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(l10n.calendarBlockedDateBadge, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (daySessions.isEmpty) Text(l10n.calendarNoSessionsOnDay, style: const TextStyle(color: Colors.black54)),
                          for (final session in daySessions)
                            _SessionTile(
                              session: session,
                              swimClass: classesById[session.classId],
                              onTap: () => showSessionFormDialog(context, ref, date: selectedDay, classes: classes, existing: session),
                              onDelete: () async {
                                final confirmed = await _confirm(
                                  context,
                                  title: l10n.calendarDeleteSessionTitle,
                                  content: l10n.calendarDeleteSessionContent,
                                );
                                if (confirmed) await ref.read(sessionsRepositoryProvider).delete(session.id);
                              },
                            ),
                        ],
                      ),
                    ),
                  );

                  // The two-pane side-by-side layout assumes a wide screen;
                  // on mobile the panes stack vertically instead. Expanded
                  // can't be used in the mobile Column branch — this body
                  // sits inside AdminPageScaffold's SingleChildScrollView,
                  // which gives unbounded height, and a flexed child inside
                  // an unbounded Column throws a layout error. Desktop keeps
                  // Expanded/flex since Row's cross axis (height) is
                  // unaffected by the scrollable ancestor.
                  if (context.isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        calendarCard,
                        const SizedBox(height: 20),
                        sessionListCard,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: calendarCard),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: sessionListCard),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.swimClass, required this.onTap, required this.onDelete});

  final SwimSession session;
  final SwimClass? swimClass;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(swimClass?.title ?? session.classId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text('${session.formattedTimeRange()} · ${l10n.calendarSessionBookedCount(session.bookedCount, session.capacity)}'
          '${session.waitlistCount > 0 ? ' · ${l10n.calendarSessionWaitlistedCount(session.waitlistCount)}' : ''}'),
      onTap: onTap,
      trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: onDelete),
      dense: true,
    );
  }
}

class _BlockedDatesDialog extends ConsumerStatefulWidget {
  const _BlockedDatesDialog();

  @override
  ConsumerState<_BlockedDatesDialog> createState() => _BlockedDatesDialogState();
}

class _BlockedDatesDialogState extends ConsumerState<_BlockedDatesDialog> {
  DateTime _date = DateTime.now();
  final _reasonCtrl = TextEditingController();
  String? _branchId; // null = all branches
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _add() async {
    if (_reasonCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    await ref.read(blockedDatesRepositoryProvider).create(
          date: _date,
          branchId: _branchId,
          reason: _reasonCtrl.text.trim(),
        );
    _reasonCtrl.clear();
    if (mounted) setState(() => _isSaving = false);
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final blockedStream = ref.watch(blockedDatesRepositoryProvider).watchAll();
    final branchesStream = ref.watch(branchesRepositoryProvider).watchAll();

    return ResponsiveDialogShell(
      title: l10n.calendarManageBlockedDates,
      desktopWidth: 480,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _pickDate, child: Text(l10n.calendarDateLabel(_fmt(_date))))),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<List<Branch>>(
                    stream: branchesStream,
                    builder: (context, snap) {
                      final branches = snap.data ?? const [];
                      return DropdownButtonFormField<String?>(
                        initialValue: _branchId,
                        decoration: InputDecoration(labelText: l10n.calendarBranchLabel),
                        items: [
                          DropdownMenuItem<String?>(value: null, child: Text(l10n.calendarAllBranchesOption)),
                          for (final b in branches) DropdownMenuItem<String?>(value: b.id, child: Text(b.name)),
                        ],
                        onChanged: (v) => setState(() => _branchId = v),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _reasonCtrl, decoration: InputDecoration(labelText: l10n.calendarReasonLabel)),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _add,
                icon: const Icon(Icons.add),
                label: Text(_isSaving ? l10n.calendarAdding : l10n.calendarAddBlockedDate),
              ),
            ),
            const Divider(height: 28),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.calendarCurrentlyBlocked, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 260,
              child: StreamBuilder<List<BlockedDate>>(
                stream: blockedStream,
                builder: (context, snap) {
                  final blocked = snap.data ?? const [];
                  if (blocked.isEmpty) {
                    return Center(child: Text(l10n.calendarNoBlockedDates, style: const TextStyle(color: Colors.black54)));
                  }
                  return StreamBuilder<List<Branch>>(
                    stream: branchesStream,
                    builder: (context, branchSnap) {
                      final branchesById = {for (final b in branchSnap.data ?? const <Branch>[]) b.id: b.name};
                      return ListView(
                        children: [
                          for (final bd in blocked)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.block, color: Colors.redAccent),
                              title: Text(_fmt(bd.date)),
                              subtitle: Text('${bd.branchId == null ? l10n.calendarAllBranchesOption : (branchesById[bd.branchId] ?? bd.branchId!)} · ${bd.reason}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final confirmed = await CalendarScreen._confirm(
                                    context,
                                    title: l10n.calendarUnblockDateTitle,
                                    content: l10n.calendarUnblockDateContent(_fmt(bd.date)),
                                  );
                                  if (confirmed) await ref.read(blockedDatesRepositoryProvider).delete(bd.id);
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonClose)),
      ],
    );
  }
}
