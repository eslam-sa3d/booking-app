import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/widgets/avatar_placeholder.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/section_header.dart';
import '../auth/auth_controller.dart';
import 'home_providers.dart';
import 'widgets/banner_carousel.dart';
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

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(classesProvider);
            await ref.read(classesProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push('/profile'),
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
              BannerCarousel(isArabic: isArabic),
              const SizedBox(height: 24),
              Text(l10n.homeCategories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const CategoryChips(),
              const SizedBox(height: 24),
              SectionHeader(title: l10n.homeFeaturedClasses),
              const SizedBox(height: 12),
              classesAsync.when(
                loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
                error: (err, st) => ErrorView(onRetry: () => ref.invalidate(classesProvider)),
                data: (classes) {
                  if (classes.isEmpty) {
                    return EmptyState(icon: Icons.search_off_rounded, message: l10n.emptyStateTitle);
                  }
                  final instructors = instructorsAsync.value ?? const {};
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: classes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final swimClass = classes[index];
                      return ClassCard(
                        swimClass: swimClass,
                        instructor: instructors[swimClass.instructorId],
                        isArabic: isArabic,
                        onTap: () => context.push('/class/${swimClass.id}'),
                      );
                    },
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
