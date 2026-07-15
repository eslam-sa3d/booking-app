import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/notifications/fcm_token_registrar.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';

class SwimAcademyApp extends ConsumerWidget {
  const SwimAcademyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Registers/refreshes the device's FCM token whenever a user signs in
    // — best-effort, see FcmTokenRegistrar for why failures are swallowed.
    ref.listen(currentUserProvider, (previous, next) {
      if (previous == null && next != null) {
        ref.read(fcmTokenRegistrarProvider).registerForCurrentUser();
      }
    });

    return MaterialApp.router(
      title: 'Swim Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
