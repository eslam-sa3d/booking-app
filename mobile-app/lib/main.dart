import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/cache/local_cache.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/providers/shared_preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  await LocalCache.init();
  final prefs = await SharedPreferences.getInstance();

  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  if (isIOS) {
    await LiquidGlassWidgets.initialize();
  }

  Widget app = const SwimAcademyApp();
  if (isIOS) {
    app = LiquidGlassWidgets.wrap(child: app);
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: app,
    ),
  );
}
