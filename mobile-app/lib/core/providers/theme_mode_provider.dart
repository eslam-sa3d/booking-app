import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_preferences_provider.dart';

const _kThemeModeKey = 'app_theme_mode';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this.ref) : super(_initialMode(ref));

  final Ref ref;

  static ThemeMode _initialMode(Ref ref) {
    final saved = ref.read(sharedPreferencesProvider).getString(_kThemeModeKey);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_kThemeModeKey, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref);
});
