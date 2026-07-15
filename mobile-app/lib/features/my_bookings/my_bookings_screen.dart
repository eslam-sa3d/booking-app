import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/utils/enum_localizations.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/models.dart';
import '../../data/repositories/booking_repository.dart';
import '../auth/auth_controller.dart';
import 'my_bookings_providers.dart';
import '../../core/widgets/glass_app_bar.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelBooking(BookingViewData data) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.myBookingsCancel),
        content: Text(l10n.myBookingsCancelConfirm(l10n.myBookingsCancellationPolicy)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.actionYes)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(data.booking.id);
      ref.invalidate(myBookingsProvider);
    } on CancellationNotAllowedException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.myBookingsCancelTooLate)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    }
  }

  Future<void> _reschedule(BookingViewData data) async {
    if (data.swimClass == null) return;
    final l10n = AppLocalizations.of(context)!;
    final sessions = await ref.read(classRepositoryProvider).getSessionsForClass(data.swimClass!.id);
    if (!mounted) return;
    final selected = await showAppBottomSheet<SwimSession>(
      context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.myBookingsReschedule, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ...sessions.map(
              (s) => ListTile(
                title: Text(AppDateFormat.weekdayDayMonth(s.date, Localizations.localeOf(ctx).languageCode)),
                subtitle: Text(s.formattedTimeRange()),
                onTap: () => Navigator.pop(ctx, s),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await ref.read(bookingRepositoryProvider).rescheduleBooking(data.booking.id, selected.id);
    ref.invalidate(myBookingsProvider);
  }

  Future<void> _rate(BookingViewData data) async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null || data.session == null || data.swimClass == null) return;
    int rating = 5;
    final commentController = TextEditingController();
    final submitted = await showAppDialog<bool>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.myBookingsRateSession),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => rating = starIndex),
                    icon: Icon(
                      starIndex <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              TextField(controller: commentController, maxLines: 2, decoration: const InputDecoration(hintText: '…')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.actionConfirm)),
          ],
        ),
      ),
    );
    if (submitted != true) return;
    await ref.read(reviewRepositoryProvider).addReview(
          Review(
            id: '',
            userId: user.id,
            userName: user.name,
            sessionId: data.session!.id,
            classId: data.swimClass!.id,
            instructorId: data.swimClass!.instructorId,
            rating: rating,
            comment: commentController.text,
            createdAt: DateTime.now(),
          ),
        );
    ref.invalidate(myBookingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(l10n.myBookingsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l10n.myBookingsUpcoming), Tab(text: l10n.myBookingsPast)],
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(onRetry: () => ref.invalidate(myBookingsProvider)),
        data: (allBookings) {
          final upcoming = allBookings.where((b) => !b.isPast && b.booking.status != BookingStatus.cancelled).toList();
          final past = allBookings.where((b) => b.isPast || b.booking.status == BookingStatus.cancelled).toList();

          Widget buildList(List<BookingViewData> items) {
            if (items.isEmpty) {
              return EmptyState(icon: Icons.event_note_rounded, message: l10n.myBookingsEmpty);
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myBookingsProvider);
                await ref.read(myBookingsProvider.future);
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final data = items[index];
                  final swimClass = data.swimClass;
                  final session = data.session;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  swimClass?.localizedTitle(isArabic) ?? '—',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                              StatusChip(label: data.booking.status.label(l10n), status: data.booking.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(data.booking.participantName, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          if (session != null)
                            Text(
                              '${AppDateFormat.weekdayDayMonth(session.date, locale)} · ${session.formattedTimeRange()}',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (!data.isPast && data.booking.status != BookingStatus.cancelled) ...[
                                AppButton(
                                  label: l10n.myBookingsReschedule,
                                  outlined: true,
                                  compact: true,
                                  onPressed: () => _reschedule(data),
                                ),
                                Semantics(
                                  button: true,
                                  label: l10n.myBookingsCancel,
                                  child: AppButton(
                                    label: l10n.myBookingsCancel,
                                    outlined: true,
                                    compact: true,
                                    onPressed: () => _cancelBooking(data),
                                  ),
                                ),
                              ],
                              if (data.isPast && data.booking.status == BookingStatus.completed && !data.booking.reviewed)
                                AppButton(
                                  label: l10n.myBookingsRateSession,
                                  outlined: true,
                                  compact: true,
                                  onPressed: () => _rate(data),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [buildList(upcoming), buildList(past)],
          );
        },
      ),
    );
  }
}
