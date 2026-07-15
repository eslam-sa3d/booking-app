import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';
import '../family/family_providers.dart';

/// Shows the participant/recurrence booking sheet for [session] (of
/// [swimClass]). On success, pushes the booking-confirmation route with the
/// resulting [BookingResult]s. Reused from both Class Details and the
/// Booking Calendar screen.
Future<void> showBookingSheet(
  BuildContext context, {
  required SwimSession session,
  required SwimClass swimClass,
}) async {
  await showAppBottomSheet(
    context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _BookingSheetContent(session: session, swimClass: swimClass),
  );
}

class _BookingSheetContent extends ConsumerStatefulWidget {
  const _BookingSheetContent({required this.session, required this.swimClass});

  final SwimSession session;
  final SwimClass swimClass;

  @override
  ConsumerState<_BookingSheetContent> createState() => _BookingSheetContentState();
}

class _BookingSheetContentState extends ConsumerState<_BookingSheetContent> {
  String? _participantId;
  String? _participantName;
  bool _recurring = false;
  int _weeks = 4;
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null || _participantId == null) return;

    setState(() => _isSubmitting = true);
    try {
      final results = await ref.read(bookingRepositoryProvider).createBooking(
            userId: user.id,
            sessionId: widget.session.id,
            participantId: _participantId!,
            participantName: _participantName!,
            recurringWeeks: _recurring ? _weeks : 1,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/booking-confirmation', extra: {
        'results': results,
        'session': widget.session,
        'swimClass': widget.swimClass,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final user = ref.watch(currentUserProvider);
    final familyAsync = ref.watch(familyMembersProvider);

    if (user == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 40),
            const SizedBox(height: 12),
            Text(l10n.authLoginTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l10n.authLoginSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.authLogin,
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/login');
              },
            ),
          ],
        ),
      );
    }

    final isFull = widget.session.isFull;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.swimClass.localizedTitle(Localizations.localeOf(context).languageCode == 'ar'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppDateFormat.weekdayDayMonth(widget.session.date, locale)} · ${widget.session.formattedTimeRange()}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(l10n.calendarSelectParticipant, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.calendarSelectParticipantSelf),
            value: user.id,
            groupValue: _participantId,
            onChanged: (v) => setState(() {
              _participantId = v;
              _participantName = user.name;
            }),
          ),
          familyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (members) => Column(
              children: members
                  .map(
                    (m) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.name),
                      value: m.id,
                      groupValue: _participantId,
                      onChanged: (v) => setState(() {
                        _participantId = v;
                        _participantName = m.name;
                      }),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.calendarRecurringOption),
            value: _recurring,
            onChanged: (v) => setState(() => _recurring = v),
          ),
          if (_recurring)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(l10n.calendarRecurringWeeks),
                  const Spacer(),
                  IconButton(
                    onPressed: _weeks > 2 ? () => setState(() => _weeks--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_weeks', style: const TextStyle(fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: _weeks < 12 ? () => setState(() => _weeks++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          AppButton(
            label: isFull ? l10n.calendarJoinWaitlist : l10n.calendarConfirmBooking,
            isLoading: _isSubmitting,
            onPressed: _participantId == null ? null : _confirm,
          ),
        ],
      ),
    );
  }
}
