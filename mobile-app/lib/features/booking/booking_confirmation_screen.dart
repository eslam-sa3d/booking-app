import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/app_button.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/models.dart';
import '../classes/class_details_providers.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.results,
    required this.session,
    required this.swimClass,
  });

  final List<BookingResult> results;
  final SwimSession session;
  final SwimClass swimClass;

  Future<void> _addToCalendar(BuildContext context, WidgetRef ref, bool isArabic) async {
    String location = '';
    try {
      final branch = await ref.read(branchByIdProvider(swimClass.branchId).future);
      location = branch.localizedName(isArabic);
    } catch (_) {
      // Branch lookup is best-effort; the calendar event is still useful without it.
    }
    Add2Calendar.addEvent2Cal(
      Event(
        title: swimClass.localizedTitle(isArabic),
        description: swimClass.localizedDescription(isArabic),
        location: location,
        startDate: session.startDateTime,
        endDate: session.endDateTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final anyWaitlisted = results.any((r) => r.joinedWaitlist);
    final color = anyWaitlisted ? AppColors.warning : AppColors.success;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(
                  anyWaitlisted ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                  color: color,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                anyWaitlisted ? l10n.bookingWaitlistTitle : l10n.bookingConfirmationTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                anyWaitlisted ? l10n.bookingWaitlistSubtitle : l10n.bookingConfirmationSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(swimClass.localizedTitle(isArabic), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    _Row(icon: Icons.event_rounded, text: AppDateFormat.weekdayDayMonth(session.date, locale)),
                    _Row(icon: Icons.access_time_rounded, text: session.formattedTimeRange()),
                    _Row(
                      icon: Icons.groups_rounded,
                      text: results.map((r) => r.booking.participantName).toSet().join(', '),
                    ),
                    if (results.length > 1)
                      _Row(icon: Icons.repeat_rounded, text: '${results.length} weeks'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: l10n.bookingConfirmationAddToCalendar,
                  child: AppButton(
                    label: l10n.bookingConfirmationAddToCalendar,
                    icon: Icons.calendar_today_outlined,
                    outlined: true,
                    onPressed: () => _addToCalendar(context, ref, isArabic),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.bookingConfirmationViewBookings,
                  onPressed: () => context.go('/bookings'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(l10n.bookingConfirmationBackHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
