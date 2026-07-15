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

  @override
  Future<void> sendOtp({required String destination}) async {
    await _delay();
  }

  @override
  Future<bool> verifyOtp({required String destination, required String code}) async {
    await _delay();
    return code.trim().length == 4 || code.trim() == '0000';
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
  AuthException(this.message);
  @override
  String toString() => message;
}
