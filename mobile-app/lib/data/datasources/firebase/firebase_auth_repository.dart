import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../models/models.dart';
import '../../repositories/auth_repository.dart';
import '../mock/mock_auth_repository.dart' show AuthException;

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _db.collection('users').doc(uid);

  /// The `onUserCreate` Cloud Function creates `users/{uid}` asynchronously
  /// right after account creation — poll briefly rather than assuming it's
  /// already there the instant `createUser` resolves.
  Future<AppUser> _waitForUserDoc(String uid) async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final snap = await _userDoc(uid).get();
      if (snap.exists) return AppUser.fromMap(snap.data()!);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    throw AuthException('Account created but profile setup is taking longer than expected. Please try logging in again.');
  }

  @override
  Future<AppUser> login({required String identifier, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: identifier.trim(), password: password);
      final snap = await _userDoc(credential.user!.uid).get();
      if (!snap.exists) return _waitForUserDoc(credential.user!.uid);
      return AppUser.fromMap(snap.data()!);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await credential.user!.updateDisplayName(name);
      final user = await _waitForUserDoc(credential.user!.uid);
      final updated = user.copyWith(name: name, phone: phone);
      await _userDoc(user.id).set(updated.toMap(), SetOptions(merge: true));
      return updated;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  @override
  Future<void> sendOtp({required String destination}) async {
    // TODO(next phase): SMS/email OTP requires a provider (e.g. Firebase
    // Phone Auth for SMS); email verification below covers the email case.
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<bool> verifyOtp({required String destination, required String code}) async {
    // TODO(next phase): wire to real OTP verification once a provider is
    // chosen. Email-link/SMS verification doesn't use a 4-digit code
    // entered in-app the way this UI expects.
    return code.trim().length == 4 || code.trim() == '0000';
  }

  @override
  Future<void> sendPasswordResetLink({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {
    // Firebase's client SDK can't reset another account's password
    // out-of-band — sendPasswordResetLink's emailed link is the real flow.
    // This exists to satisfy the interface for the mock-parity form.
    final user = _auth.currentUser;
    if (user != null) await user.updatePassword(newPassword);
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<AppUser?> currentUser() async {
    final user = await _auth.authStateChanges().first;
    if (user == null) return null;
    final snap = await _userDoc(user.uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.data()!);
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _userDoc(user.id).set(user.toMap(), SetOptions(merge: true));
    return user;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await _userDoc(userId).delete();
    await _auth.currentUser?.delete();
  }

  String _mapAuthError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email/phone or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
