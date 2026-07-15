import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/page_scaffold.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        return AdminPageScaffold(
          title: 'Calendar & Sessions',
          actions: [
            OutlinedButton.icon(
              onPressed: classes.isEmpty ? null : () => showRecurringSessionDialog(context, ref, classes: classes),
              icon: const Icon(Icons.repeat_rounded),
              label: const Text('Bulk-create recurring'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: classes.isEmpty ? null : () => showSessionFormDialog(context, ref, date: selectedDay, classes: classes),
              icon: const Icon(Icons.add),
              label: const Text('Add session'),
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

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TableCalendar(
                          firstDay: DateTime.now().subtract(const Duration(days: 365)),
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          focusedDay: focusedMonth,
                          selectedDayPredicate: (d) => isSameDay(d, selectedDay),
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
                          calendarStyle: const CalendarStyle(
                            selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            todayDecoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            markerDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            if (daySessions.isEmpty) const Text('No sessions on this day', style: TextStyle(color: Colors.black54)),
                            for (final session in daySessions)
                              _SessionTile(
                                session: session,
                                swimClass: classesById[session.classId],
                                onTap: () => showSessionFormDialog(context, ref, date: selectedDay, classes: classes, existing: session),
                                onDelete: () => ref.read(sessionsRepositoryProvider).delete(session.id),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(swimClass?.title ?? session.classId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text('${session.formattedTimeRange()} · ${session.bookedCount}/${session.capacity} booked'
          '${session.waitlistCount > 0 ? ' · ${session.waitlistCount} waitlisted' : ''}'),
      onTap: onTap,
      trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: onDelete),
      dense: true,
    );
  }
}
