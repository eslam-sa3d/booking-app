import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'shared_preferences_provider.dart';

const _kBiometricLockEnabledKey = 'biometric_lock_enabled';

final localAuthProvider = Provider<LocalAuthentication>((ref) => LocalAuthentication());

class BiometricLockController extends StateNotifier<bool> {
  BiometricLockController(this.ref) : super(_initial(ref));

  final Ref ref;

  static bool _initial(Ref ref) {
    return ref.read(sharedPreferencesProvider).getBool(_kBiometricLockEnabledKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_kBiometricLockEnabledKey, enabled);
  }
}

final biometricLockEnabledProvider = StateNotifierProvider<BiometricLockController, bool>((ref) {
  return BiometricLockController(ref);
});
