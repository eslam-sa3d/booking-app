import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase/firebase_app_settings_repository.dart';
import '../../data/models/models.dart';

/// One-shot fetch of the admin-editable `appSettings/config` singleton —
/// FAQ copy, terms/privacy links, and support contact details. A plain
/// FutureProvider is enough since this rarely changes and every consumer
/// just needs the latest value when the screen opens.
final appSettingsFutureProvider = FutureProvider<AppSettings>((ref) {
  return ref.watch(appSettingsRepositoryProvider).getSettings();
});
