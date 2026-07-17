import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

const kOnboardingSeenKey = 'onboarding_seen';

/// Pure loading UI — where to go next is decided entirely by the router's
/// `redirect` callback once auth state resolves (see app_router.dart), so
/// this screen has no navigation logic of its own.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
