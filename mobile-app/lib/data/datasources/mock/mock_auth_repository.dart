import 'dart:io';

import '../../models/models.dart';
import '../../repositories/auth_repository.dart';
import 'mock_database.dart';

class MockAuthRepository implements AuthRepository {
  final _db = MockDatabase.instance;

  // In-memory only — unlike Firebase Auth, the mock has no real persisted
  // session, so this resets on every app restart (acceptable: it's a dev
  // stand-in, not used once the Firebase repositories are wired in).
  String? _currentUserId;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<AppUser> login({required String identifier, required String password}) async {
    await _delay();
    final email = identifier.trim().toLowerCase();
    final storedPassword = _db.passwordsByEmail[email];
    if (storedPassword == null || storedPassword != password) {
      throw AuthException('Invalid email/phone or password.');
    }
    final user = _db.users.values.firstWhere((u) => u.email.toLowerCase() == email);
    _currentUserId = user.id;
    return user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _delay();
    final normalizedEmail = email.trim().toLowerCase();
    if (_db.passwordsByEmail.containsKey(normalizedEmail)) {
      throw AuthException('An account with this email already exists.');
    }
    final id = _db.nextId('u');
    final user = AppUser(
      id: id,
      name: name,
      email: normalizedEmail,
      phone: phone,
      createdAt: DateTime.now(),
    );
    _db.users[id] = user;
    _db.passwordsByEmail[normalizedEmail] = password;
    _currentUserId = id;
    return user;
  }

  // Hermetic stand-in for Firebase Phone Auth: there's no real SMS
  // provider to talk to in tests, so this "sends" instantly and hands back
  // a fake verification id keyed to the phone number. verifyOtp below
  // accepts any well-formed 4-digit code (or the well-known "0000"), same
  // relaxed rule the old fake OTP used, purely so widget tests can drive
  // the flow without real SMS.
  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AppUser user) onAutoVerified,
    required void Function(String message) onFailed,
  }) async {
    await _delay();
    onCodeSent('mock-verification-id:$phoneNumber');
  }

  @override
  Future<AppUser> verifyOtp({required String verificationId, required String code}) async {
    await _delay();
    final trimmed = code.trim();
    if (trimmed != '0000' && trimmed.length != 4) {
      throw AuthException('Invalid verification code.');
    }
    final id = _currentUserId;
    if (id == null) {
      throw AuthException('No account in progress to verify.');
    }
    return _db.users[id]!;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    await _delay();
    // Simulates a Google account that either already exists (repeat
    // "sign-in") or is provisioned on first use, the same way a real
    // first-time Google user gets a Firestore profile via onUserCreate.
    const email = 'mock.google.user@example.com';
    final existing = _db.users.values.where((u) => u.email == email);
    AppUser user;
    if (existing.isNotEmpty) {
      user = existing.first;
    } else {
      final id = _db.nextId('u');
      user = AppUser(id: id, name: 'Google User', email: email, phone: '', createdAt: DateTime.now());
      _db.users[id] = user;
    }
    _currentUserId = user.id;
    return user;
  }

  @override
  Future<void> sendPasswordResetLink({required String email}) async {
    await _delay();
    if (!_db.passwordsByEmail.containsKey(email.trim().toLowerCase())) {
      throw AuthException('No account found with this email.');
    }
  }

  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {
    await _delay();
    final normalizedEmail = email.trim().toLowerCase();
    if (!_db.passwordsByEmail.containsKey(normalizedEmail)) {
      throw AuthException('No account found with this email.');
    }
    _db.passwordsByEmail[normalizedEmail] = newPassword;
  }

  @override
  Future<void> logout() async {
    await _delay();
    _currentUserId = null;
  }

  @override
  Future<AppUser?> currentUser() async {
    await _delay();
    final id = _currentUserId;
    return id == null ? null : _db.users[id];
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _delay();
    _db.users[user.id] = user;
    return user;
  }

  // Mock has no real re-auth session concept — email changes apply
  // immediately rather than going through a "requires-recent-login" retry,
  // since there's nothing stale to expire.
  @override
  Future<void> updateEmail(String newEmail) async {
    await _delay();
    final id = _currentUserId;
    if (id == null) throw AuthException('You must be signed in to do this.');
    final normalized = newEmail.trim().toLowerCase();
    final user = _db.users[id]!;
    final password = _db.passwordsByEmail.remove(user.email);
    if (password != null) _db.passwordsByEmail[normalized] = password;
    _db.users[id] = user.copyWith(email: normalized);
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    await _delay();
    final id = _currentUserId;
    if (id == null) throw AuthException('You must be signed in to do this.');
    final user = _db.users[id]!;
    final stored = _db.passwordsByEmail[user.email.toLowerCase()];
    if (stored == null || stored != password) {
      throw AuthException('Incorrect password.', code: 'wrong-password');
    }
  }

  @override
  Future<String> uploadProfilePhoto(File file) async {
    await _delay();
    // No real storage backend in the mock — hand back a stable fake URL so
    // widget tests can assert a photoUrl was set without touching disk I/O.
    return 'https://mock.local/avatars/${_currentUserId ?? 'guest'}.jpg';
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await _delay();
    final user = _db.users.remove(userId);
    if (user != null) {
      _db.passwordsByEmail.remove(user.email);
    }
    if (_currentUserId == userId) _currentUserId = null;
  }
}

class AuthException implements Exception {
  final String message;
  final String? code;
  AuthException(this.message, {this.code});
  @override
  String toString() => message;
}
