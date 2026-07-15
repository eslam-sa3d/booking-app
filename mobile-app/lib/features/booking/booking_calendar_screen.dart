import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import 'booking_providers.dart';
import 'booking_sheet.dart';
import '../../core/widgets/glass_app_bar.dart';

enum _CalendarViewMode { month, week, day }

class BookingCalendarScreen extends ConsumerStatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  ConsumerState<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends ConsumerState<BookingCalendarScreen> {
  _CalendarViewMode _mode = _CalendarViewMode.month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final selectedDay = ref.watch(selectedCalendarDayProvider);
    final focusedMonth = ref.watch(focusedCalendarMonthProvider);
    final monthSessions = ref.watch(sessionsInFocusedMonthProvider);
    final daySessionsAsync = ref.watch(sessionsForSelectedDayProvider);
    final classesMapAsync = ref.watch(classesByIdMapProvider);
    final isArabic = ref.watch(isArabicProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.calendarTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<_CalendarViewMode>(
              segments: [
                ButtonSegment(value: _CalendarViewMode.month, label: Text(l10n.calendarViewMonth)),
                ButtonSegment(value: _CalendarViewMode.week, label: Text(l10n.calendarViewWeek)),
                ButtonSegment(value: _CalendarViewMode.day, label: Text(l10n.calendarViewDay)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
          ),
          if (_mode == _CalendarViewMode.day)
            _DayStrip(selectedDay: selectedDay, locale: locale)
          else
            monthSessions.when(
              data: (eventMap) => TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 1)),
                lastDay: DateTime.now().add(const Duration(days: 120)),
                focusedDay: focusedMonth.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                    ? DateTime.now()
                    : focusedMonth,
                currentDay: DateTime.now(),
                selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                calendarFormat: _mode == _CalendarViewMode.week ? CalendarFormat.week : CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: '', CalendarFormat.week: ''},
                startingDayOfWeek: StartingDayOfWeek.saturday,
                locale: locale,
                onDaySelected: (selected, focused) {
                  ref.read(selectedCalendarDayProvider.notifier).state = DateTime(selected.year, selected.month, selected.day);
                  ref.read(focusedCalendarMonthProvider.notifier).state = DateTime(focused.year, focused.month, 1);
                },
                onPageChanged: (focused) {
                  ref.read(focusedCalendarMonthProvider.notifier).state = DateTime(focused.year, focused.month, 1);
                },
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  final count = eventMap[key] ?? 0;
                  return List.filled(count > 3 ? 3 : count, 0);
                },
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ),
              loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
              error: (_, _) => const SizedBox.shrink(),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppDateFormat.fullDate(selectedDay, locale),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: daySessionsAsync.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(onRetry: () => ref.invalidate(sessionsForSelectedDayProvider)),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return EmptyState(icon: Icons.event_busy_rounded, message: l10n.calendarNoSessions);
                }
                final classesMap = classesMapAsync.value ?? const {};
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final swimClass = classesMap[session.classId];
                    if (swimClass == null) return const SizedBox.shrink();
                    return Card(
                      child: ListTile(
                        title: Text(swimClass.localizedTitle(isArabic)),
                        subtitle: Text(
                          '${session.formattedTimeRange()} · ${session.isFull ? l10n.calendarFull : l10n.calendarSpotsLeft(session.spotsLeft, session.capacity)}',
                        ),
                        trailing: FilledButton(
                          onPressed: () => showBookingSheet(context, session: session, swimClass: swimClass),
                          child: Text(session.isFull ? l10n.calendarJoinWaitlist : l10n.homeBookNow),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayStrip extends ConsumerWidget {
  const _DayStrip({required this.selectedDay, required this.locale});

  final DateTime selectedDay;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final days = List.generate(14, (i) => DateTime(today.year, today.month, today.day + i));

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = isSameDay(day, selectedDay);
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => ref.read(selectedCalendarDayProvider.notifier).state = day,
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).dividerColor),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppDateFormat.dayMonth(day, locale).split(' ').first,
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${day.day}',
                    style: TextStyle(color: isSelected ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
