class SwimSession {
  final String id;
  final String classId;
  final DateTime date;
  final int startMinutes; // minutes from midnight, e.g. 16:30 -> 990
  final int endMinutes;
  final int capacity;
  final int bookedCount;
  final int waitlistCount;
  final String instructorId;
  final String branchId;

  const SwimSession({
    required this.id,
    required this.classId,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.capacity,
    this.bookedCount = 0,
    this.waitlistCount = 0,
    required this.instructorId,
    required this.branchId,
  });

  int get spotsLeft => (capacity - bookedCount).clamp(0, capacity);
  bool get isFull => spotsLeft <= 0;
  bool get isPast => date.add(Duration(minutes: endMinutes)).isBefore(DateTime.now());

  DateTime get startDateTime =>
      DateTime(date.year, date.month, date.day).add(Duration(minutes: startMinutes));
  DateTime get endDateTime =>
      DateTime(date.year, date.month, date.day).add(Duration(minutes: endMinutes));

  String formattedTimeRange() {
    String fmt(int minutes) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      final period = h >= 12 ? 'PM' : 'AM';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      return '$h12:${m.toString().padLeft(2, '0')} $period';
    }

    return '${fmt(startMinutes)} - ${fmt(endMinutes)}';
  }

  SwimSession copyWith({int? bookedCount, int? waitlistCount}) {
    return SwimSession(
      id: id,
      classId: classId,
      date: date,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      capacity: capacity,
      bookedCount: bookedCount ?? this.bookedCount,
      waitlistCount: waitlistCount ?? this.waitlistCount,
      instructorId: instructorId,
      branchId: branchId,
    );
  }
}
