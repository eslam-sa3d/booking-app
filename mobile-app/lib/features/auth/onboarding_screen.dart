import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import 'splash_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _finish() {
    ref.read(sharedPreferencesProvider).setBool(kOnboardingSeenKey, true);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      (Icons.pool_rounded, l10n.onboardTitle1, l10n.onboardSubtitle1),
      (Icons.calendar_month_rounded, l10n.onboardTitle2, l10n.onboardSubtitle2),
      (Icons.emoji_events_rounded, l10n.onboardTitle3, l10n.onboardSubtitle3),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextButton(onPressed: _finish, child: Text(l10n.actionSkip)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final (icon, title, subtitle) = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 64, color: AppColors.primary),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _page == pages.length - 1 ? l10n.actionGetStarted : l10n.actionNext,
                  onPressed: () {
                    if (_page == pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
