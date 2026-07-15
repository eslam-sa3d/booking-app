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
  final result = <BookingViewData>[];
  for (final booking in bookings) {
    final session = await classRepo.getSessionById(booking.sessionId);
    final swimClass = session != null ? await classRepo.getClassById(session.classId) : null;
    result.add(BookingViewData(booking: booking, session: session, swimClass: swimClass));
  }
  return result;
});
