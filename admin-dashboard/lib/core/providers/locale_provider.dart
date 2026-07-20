import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }

  void toggle() => setLocale(state.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref);
});

final isArabicProvider = Provider<bool>((ref) => ref.watch(localeProvider).languageCode == 'ar');
