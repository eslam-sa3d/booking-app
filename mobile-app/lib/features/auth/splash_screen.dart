import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/shared_preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import 'auth_controller.dart';

const kOnboardingSeenKey = 'onboarding_seen';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveDestination());
  }

  Future<void> _resolveDestination() async {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await ref.read(authControllerProvider.future);
    if (!mounted) return;

    final seenOnboarding = prefs.getBool(kOnboardingSeenKey) ?? false;
    if (!seenOnboarding) {
      context.go('/onboarding');
      return;
    }

    // Guests can browse Home freely; booking/profile actions gate on login individually.
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pool_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 20),
            const Text(
              'Swim Academy',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
