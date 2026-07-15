import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

final selectedCalendarDayProvider = StateProvider<DateTime>((ref) => _dateOnly(DateTime.now()));
final focusedCalendarMonthProvider = StateProvider<DateTime>((ref) => _dateOnly(DateTime.now()));

final sessionsForSelectedDayProvider = FutureProvider<List<SwimSession>>((ref) {
  final day = ref.watch(selectedCalendarDayProvider);
  return ref.watch(classRepositoryProvider).getSessionsForDate(day);
});

final classesByIdMapProvider = FutureProvider<Map<String, SwimClass>>((ref) async {
  final classes = await ref.watch(classRepositoryProvider).getClasses();
  return {for (final c in classes) c.id: c};
});

/// All sessions in the currently focused month, keyed by day-only DateTime —
/// used to render "has sessions" dots on the calendar.
final sessionsInFocusedMonthProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final month = ref.watch(focusedCalendarMonthProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0);
  final sessions = await ref.watch(classRepositoryProvider).getSessionsInRange(start, end);
  final map = <DateTime, int>{};
  for (final s in sessions) {
    final key = _dateOnly(s.date);
    map[key] = (map[key] ?? 0) + 1;
  }
  return map;
});
