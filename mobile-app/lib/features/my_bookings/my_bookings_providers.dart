import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';

class BookingViewData {
  final Booking booking;
  final SwimSession? session;
  final SwimClass? swimClass;
  const BookingViewData({required this.booking, this.session, this.swimClass});

  bool get isPast => session == null ? booking.status == BookingStatus.completed : session!.isPast;
}

final myBookingsProvider = FutureProvider<List<BookingViewData>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final bookingRepo = ref.watch(bookingRepositoryProvider);
  final classRepo = ref.watch(classRepositoryProvider);

  final bookings = await bookingRepo.getBookingsForUser(user.id);

  // Fetch each booking's session concurrently instead of one at a time.
  final sessions = await Future.wait(bookings.map((b) => classRepo.getSessionById(b.sessionId)));

  // A recurring booking's weekly sessions share the same class — fetch
  // each distinct classId once instead of refetching it per booking.
  final classIds = sessions.whereType<SwimSession>().map((s) => s.classId).toSet();
  final classEntries = await Future.wait(
    classIds.map((id) async => MapEntry(id, await classRepo.getClassById(id))),
  );
  final classesById = Map.fromEntries(classEntries);

  return [
    for (var i = 0; i < bookings.length; i++)
      BookingViewData(
        booking: bookings[i],
        session: sessions[i],
        swimClass: sessions[i] != null ? classesById[sessions[i]!.classId] : null,
      ),
  ];
});
