import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    return ref.read(authRepositoryProvider).currentUser();
  }

  Future<void> login({required String identifier, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(authRepositoryProvider).login(identifier: identifier, password: password);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            phone: phone,
            password: password,
          );
    });
  }

  Future<void> updateProfile(AppUser user) async {
    final updated = await ref.read(authRepositoryProvider).updateProfile(user);
    state = AsyncData(updated);
  }

  /// Signs in via Google OAuth. A dismissed account picker resolves to null
  /// from the repository (not an exception) — restore whatever user was
  /// signed in before rather than surfacing that as an error.
  Future<void> signInWithGoogle() async {
    final previousUser = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      return user ?? previousUser;
    });
  }

  /// Reflects an [AppUser] that was already produced by an out-of-band
  /// mutation (e.g. phone OTP verification completed by [OtpScreen] calling
  /// the repository directly) into shared auth state, without a redundant
  /// repository round-trip.
  void setUser(AppUser user) {
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    final user = state.value;
    if (user == null) return;
    await ref.read(authRepositoryProvider).deleteAccount(user.id);
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).value != null;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authControllerProvider).value;
});
