import '../models/models.dart';

/// Abstract auth contract. Swap [MockAuthRepository] for a Firebase Auth
/// implementation later without touching any UI or controller code.
abstract class AuthRepository {
  Future<AppUser> login({required String identifier, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> sendOtp({required String destination});

  Future<bool> verifyOtp({required String destination, required String code});

  Future<void> sendPasswordResetLink({required String email});

  Future<void> resetPassword({required String email, required String newPassword});

  Future<void> logout();

  Future<AppUser?> restoreSession(String userId);

  Future<AppUser> updateProfile(AppUser user);

  Future<void> deleteAccount(String userId);
}
