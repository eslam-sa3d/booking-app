import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/glass.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/avatar_placeholder.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/section_header.dart';
import '../auth/auth_controller.dart';
import '../notifications/notifications_screen.dart' show unreadNotificationsCountProvider;
import 'home_providers.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/branch_filter.dart';
import 'widgets/category_chips.dart';
import 'widgets/class_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final user = ref.watch(currentUserProvider);
    final classesAsync = ref.watch(classesProvider);
    final instructorsAsync = ref.watch(instructorsMapProvider);
    final categoriesMapAsync = ref.watch(categoriesMapProvider);
    final bannersAsync = ref.watch(bannersProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    // The floating iOS glass nav bar sits outside this screen's own layout
    // (AppShell positions it on top, extending the body behind it), so the
    // bottom safe-area inset shouldn't be reserved here — SafeArea(bottom:
    // false) plus extra ListView padding lets content actually scroll
    // behind/through the translucent bar instead of stopping short and
    // leaving a dead, contentless gap below it.
    final isGlass = isLiquidGlassPlatform(context);
    return Scaffold(
      body: SafeArea(
        bottom: !isGlass,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(classesProvider);
            await ref.read(classesProvider.future);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, isGlass ? MediaQuery.of(context).padding.bottom + 100 : 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user != null ? l10n.homeGreeting(user.name.split(' ').first) : l10n.appName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: Badge.count(
                      count: unreadCount,
                      isLabelVisible: unreadCount > 0,
                      child: const Icon(Icons.notifications_outlined),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    // /profile is a StatefulShellBranch destination (the
                    // Profile tab) — go() switches the shell to it, same as
                    // tapping the tab, instead of push()ing a redundant
                    // second page instance that collides with the shell's
                    // own cached branch page.
                    onTap: () => context.go('/profile'),
                    child: AvatarPlaceholder(initials: user?.initials ?? '?', size: 36),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: l10n.homeSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 20),
              BannerCarousel(isArabic: isArabic, banners: bannersAsync.value ?? const []),
              const SizedBox(height: 24),
              Text(l10n.homeCategories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const CategoryChips(),
              const SizedBox(height: 16),
              Text(l10n.filterBranch, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const BranchFilterChips(),
              const SizedBox(height: 24),
              SectionHeader(title: l10n.homeFeaturedClasses),
              const SizedBox(height: 12),
              classesAsync.when(
                loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
                error: (err, st) => ErrorView(onRetry: () => ref.invalidate(classesProvider)),
                data: (state) {
                  final classes = state.items;
                  if (classes.isEmpty) {
                    return EmptyState(icon: Icons.search_off_rounded, message: l10n.emptyStateTitle);
                  }
                  final instructors = instructorsAsync.value ?? const {};
                  final categoriesMap = categoriesMapAsync.value ?? const {};
                  return Column(
                    children: [
                      if (state.isOffline)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  l10n.offlineBanner,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: classes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final swimClass = classes[index];
                          return ClassCard(
                            swimClass: swimClass,
                            instructor: instructors[swimClass.instructorId],
                            primaryCategory: categoriesMap[swimClass.categories.firstOrNull],
                            isArabic: isArabic,
                            onTap: () => context.push('/class/${swimClass.id}'),
                          );
                        },
                      ),
                      if (state.hasMore) ...[
                        const SizedBox(height: 16),
                        // No dedicated l10n key ships for this yet — a plain
                        // conditional keeps both locales reasonable without
                        // touching the generated l10n files (out of scope
                        // for this change).
                        Semantics(
                          button: true,
                          label: isArabic ? 'تحميل المزيد' : 'Load more',
                          child: AppButton(
                            label: isArabic ? 'تحميل المزيد' : 'Load more',
                            outlined: true,
                            isLoading: state.isLoadingMore,
                            onPressed: () => ref.read(classesProvider.notifier).loadMore(),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
