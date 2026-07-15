import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import 'shared_preferences_provider.dart';

const _kLocaleKey = 'app_locale';

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this.ref) : super(_initialLocale(ref));

  final Ref ref;

  static Locale _initialLocale(Ref ref) {
    final saved = ref.read(sharedPreferencesProvider).getString(_kLocaleKey);
    return Locale(saved ?? 'en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(_kLocaleKey, locale.languageCode);

    // Signed-in users get their language preference synced to
    // AppUser.preferredLanguage in Firestore so the backend (push copy,
    // transactional emails) can localize correctly. Guests/signed-out users
    // stay local-only — there's no profile doc to write to.
    final user = ref.read(currentUserProvider);
    if (user != null && user.preferredLanguage != locale.languageCode) {
      try {
        await ref.read(authControllerProvider.notifier).updateProfile(
              user.copyWith(preferredLanguage: locale.languageCode),
            );
      } catch (_) {
        // Best-effort — the local toggle already applied; don't block the
        // UI on a transient network/Firestore failure.
      }
    }
  }

  void toggle() => setLocale(state.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref);
});

final isArabicProvider = Provider<bool>((ref) => ref.watch(localeProvider).languageCode == 'ar');
