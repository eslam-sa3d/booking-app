import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../data/models/models.dart';

const _kSessionUserIdKey = 'session_user_id';

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedUserId = prefs.getString(_kSessionUserIdKey);
    if (savedUserId == null) return null;
    return ref.read(authRepositoryProvider).restoreSession(savedUserId);
  }

  Future<void> login({required String identifier, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(identifier: identifier, password: password);
      await _persistSession(user.id);
      return user;
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            phone: phone,
            password: password,
          );
      await _persistSession(user.id);
      return user;
    });
  }

  Future<void> updateProfile(AppUser user) async {
    final updated = await ref.read(authRepositoryProvider).updateProfile(user);
    state = AsyncData(updated);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_kSessionUserIdKey);
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    final user = state.value;
    if (user == null) return;
    await ref.read(authRepositoryProvider).deleteAccount(user.id);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_kSessionUserIdKey);
    state = const AsyncData(null);
  }

  Future<void> _persistSession(String userId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kSessionUserIdKey, userId);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).value != null;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authControllerProvider).value;
});
