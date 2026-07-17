import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/avatar_placeholder.dart';
import '../../core/widgets/class_hero_placeholder.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/models.dart';
import '../booking/booking_sheet.dart';
import '../home/home_providers.dart';
import 'class_details_providers.dart';
import '../../core/widgets/glass_app_bar.dart';

class ClassDetailsScreen extends ConsumerWidget {
  const ClassDetailsScreen({super.key, required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final classAsync = ref.watch(classByIdProvider(classId));

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.classDetailsAbout)),
      body: classAsync.when(
        loading: () => const LoadingView(),
        error: (err, st) => ErrorView(onRetry: () => ref.invalidate(classByIdProvider(classId))),
        data: (swimClass) {
          final instructorAsync = ref.watch(instructorByIdProvider(swimClass.instructorId));
          final branchAsync = ref.watch(branchByIdProvider(swimClass.branchId));
          final sessionsAsync = ref.watch(sessionsForClassProvider(classId));
          final reviewsAsync = ref.watch(reviewsForClassProvider(classId));
          final categoriesMapAsync = ref.watch(categoriesMapProvider);
          final categoriesMap = categoriesMapAsync.valueOrNull ?? const <String, Category>{};
          final locale = Localizations.localeOf(context).languageCode;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClassHeroPlaceholder(colorHex: swimClass.heroColorHex, iconName: swimClass.heroIcon, height: 180),
              const SizedBox(height: 16),
              Text(swimClass.localizedTitle(isArabic), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final categoryId in swimClass.categories)
                    if (categoriesMap[categoryId] != null)
                      Chip(
                        label: Text(categoriesMap[categoryId]!.localizedName(isArabic)),
                        visualDensity: VisualDensity.compact,
                      ),
                  Chip(
                    avatar: const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    label: Text('${swimClass.rating} (${swimClass.reviewCount})'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.classDetailsAbout, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text(swimClass.localizedDescription(isArabic)),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.timer_outlined,
                label: l10n.classDetailsDuration,
                value: l10n.classDetailsMinutes(swimClass.durationMinutes),
              ),
              _InfoRow(
                icon: Icons.payments_outlined,
                label: l10n.classDetailsPrice,
                value: '${swimClass.price.toStringAsFixed(0)} ${swimClass.currency}',
              ),
              branchAsync.when(
                data: (branch) => _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: l10n.classDetailsBranch,
                  value: branch.localizedName(isArabic),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              Text(l10n.classDetailsInstructor, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              instructorAsync.when(
                data: (instructor) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      AvatarPlaceholder(initials: instructor.initials, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(instructor.localizedName(isArabic), style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              instructor.localizedBio(isArabic),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const LoadingView(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              Text(l10n.classDetailsAvailableSessions, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              sessionsAsync.when(
                loading: () => const LoadingView(),
                error: (_, _) => ErrorView(onRetry: () => ref.invalidate(sessionsForClassProvider(classId))),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Text(l10n.calendarNoSessions);
                  }
                  return Column(
                    children: sessions.take(8).map((session) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppDateFormat.weekdayDayMonth(session.date, locale)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${session.formattedTimeRange()} · ${session.isFull ? l10n.calendarFull : l10n.calendarSpotsLeft(session.spotsLeft, session.capacity)}',
                                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              IntrinsicWidth(
                                child: FilledButton(
                                  onPressed: () => showBookingSheet(context, session: session, swimClass: swimClass),
                                  child: Text(session.isFull ? l10n.calendarJoinWaitlist : l10n.homeBookNow),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(l10n.classDetailsReviews, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              reviewsAsync.when(
                loading: () => const LoadingView(),
                error: (_, _) => const SizedBox.shrink(),
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return Text(l10n.classDetailsNoReviews, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
                  }
                  return Column(
                    children: reviews
                        .map(
                          (r) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: AvatarPlaceholder(initials: r.userName.isNotEmpty ? r.userName[0] : '?', size: 36),
                            title: Text(r.userName),
                            subtitle: Text(r.comment),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                Text('${r.rating}'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 90),
            ],
          );
        },
      ),
      bottomNavigationBar: classAsync.maybeWhen(
        data: (swimClass) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SafeArea(
            top: false,
            child: AppButton(
              label: l10n.classDetailsBookClass,
              onPressed: () async {
                final sessions = await ref.read(sessionsForClassProvider(classId).future);
                if (sessions.isEmpty || !context.mounted) return;
                showBookingSheet(context, session: sessions.first, swimClass: swimClass);
              },
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
