import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/notifications/fcm_token_registrar.dart';
import 'core/notifications/push_notification_handler.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_lock_gate.dart';

class SwimAcademyApp extends ConsumerWidget {
  const SwimAcademyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Registers/refreshes the device's FCM token on every cold start where
    // a user is signed in — see FcmTokenRegistrar.init for why this can't
    // be a plain null->user transition listener here.
    ref.watch(fcmTokenRegistrarProvider);

    // Sets up FirebaseMessaging.onMessage/onMessageOpenedApp listeners once
    // (the provider is cached, so re-reading it on rebuild is a no-op) so
    // foreground pushes are shown via flutter_local_notifications and
    // tapped pushes navigate — see PushNotificationHandler.
    ref.watch(pushNotificationHandlerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: 'Swim Academy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(dynamicScheme: lightDynamic),
          darkTheme: AppTheme.dark(dynamicScheme: darkDynamic),
          themeMode: themeMode,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
          builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
