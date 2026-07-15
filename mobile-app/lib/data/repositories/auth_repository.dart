import 'dart:io';

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

  /// Starts phone-number verification for [phoneNumber] (must already be in
  /// E.164 format, e.g. "+9665XXXXXXXX"). Exactly one of the three
  /// callbacks fires once Firebase has an outcome:
  ///  - [onCodeSent] — an SMS was actually dispatched; the given
  ///    `verificationId` must be passed back into [verifyOtp] along with
  ///    the code the user typed. It can also fire a second time (still with
  ///    no code entered yet) if Firebase's short auto-retrieval window
  ///    times out, so the UI should just keep accepting manual entry.
  ///  - [onAutoVerified] — Android was able to confirm the code itself (SMS
  ///    autofill / Play services) without the user typing anything;
  ///    sign-in/linking has already completed by the time this fires, so
  ///    the caller can skip straight past the code-entry step.
  ///  - [onFailed] — the request itself failed (bad number, quota,
  ///    network) before any code was ever sent.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AppUser user) onAutoVerified,
    required void Function(String message) onFailed,
  });

  /// Confirms the [code] the user typed against the verification started by
  /// [sendOtp], using the `verificationId` it handed back. When a user is
  /// already signed in (the registration flow: email/password account
  /// created first, phone verified as a follow-up step) the verified phone
  /// number is linked onto that account rather than starting a new session;
  /// otherwise this signs in fresh with the phone number as the primary
  /// credential.
  Future<AppUser> verifyOtp({required String verificationId, required String code});

  Future<void> sendPasswordResetLink({required String email});

  Future<void> resetPassword({required String email, required String newPassword});

  /// Signs in via Google OAuth using the native account picker. Returns
  /// null if the user dismisses the picker instead of throwing — that's a
  /// normal, silent cancellation, not an error state for the UI to surface.
  Future<AppUser?> signInWithGoogle();

  Future<void> logout();

  /// Resolves the already-signed-in user on app launch, or null if signed
  /// out. Firebase Auth persists sessions natively (keychain/IndexedDB) —
  /// this never needs a stored token from the caller.
  Future<AppUser?> currentUser();

  Future<AppUser> updateProfile(AppUser user);

  /// Changes the signed-in user's Auth email. Sends a verification link to
  /// [newEmail] rather than switching immediately (`verifyBeforeUpdateEmail`)
  /// — the address only takes effect once the user confirms it from their
  /// inbox. Throws [AuthException] with `code == 'requires-recent-login'`
  /// when the session is too old; callers should [reauthenticate] and retry.
  Future<void> updateEmail(String newEmail);

  /// Re-proves the signed-in user's identity with their current password,
  /// needed before sensitive operations (like [updateEmail]) that Firebase
  /// refuses on a stale session.
  Future<void> reauthenticate({required String password});

  /// Uploads [file] as the signed-in user's profile photo and returns its
  /// public download URL. Callers still need to persist that URL onto the
  /// user's profile via [updateProfile].
  Future<String> uploadProfilePhoto(File file);

  Future<void> deleteAccount(String userId);
}
