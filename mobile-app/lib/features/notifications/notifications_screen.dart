import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/enums.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/glass_app_bar.dart';

final notificationsProvider = FutureProvider((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(notificationRepositoryProvider).getNotifications(user.id);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_outline_rounded;
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.cancellation:
        return Icons.cancel_outlined;
      case NotificationType.waitlistPromoted:
        return Icons.hourglass_top_rounded;
      case NotificationType.packageExpiry:
        return Icons.card_membership_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final user = ref.watch(currentUserProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (user != null)
            TextButton(
              onPressed: () async {
                await ref.read(notificationRepositoryProvider).markAllAsRead(user.id);
                ref.invalidate(notificationsProvider);
              },
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(onRetry: () => ref.invalidate(notificationsProvider)),
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyState(icon: Icons.notifications_none_rounded, message: l10n.notificationsEmpty);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Card(
                color: n.isRead ? null : AppColors.primary.withValues(alpha: 0.06),
                child: ListTile(
                  leading: Icon(_iconFor(n.type), color: AppColors.primary),
                  title: Text(n.localizedTitle(isArabic), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(n.localizedBody(isArabic)),
                  trailing: Text(AppDateFormat.dayMonth(n.createdAt, locale), style: const TextStyle(fontSize: 11)),
                  onTap: () async {
                    await ref.read(notificationRepositoryProvider).markAsRead(n.id);
                    ref.invalidate(notificationsProvider);
                    if (n.relatedBookingId != null && context.mounted) context.push('/bookings');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
