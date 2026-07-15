import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/models.dart';
import '../../repositories/auth_repository.dart';
import '../mock/mock_auth_repository.dart' show AuthException;

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AppUser user) onAutoVerified,
    required void Function(String message) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      // Android only: some devices can confirm the SMS code themselves
      // (Play services autofill) without the user ever seeing the code
      // entry step. When that happens we already have a usable credential.
      verificationCompleted: (credential) async {
        try {
          final user = await _signInOrLinkWithPhoneCredential(credential);
          onAutoVerified(user);
        } on fb_auth.FirebaseAuthException catch (e) {
          onFailed(_mapAuthError(e));
        }
      },
      verificationFailed: (e) => onFailed(_mapAuthError(e)),
      codeSent: (verificationId, forceResendingToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (verificationId) => onCodeSent(verificationId),
    );
  }

  @override
  Future<AppUser> verifyOtp({required String verificationId, required String code}) async {
    final credential = fb_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code.trim(),
    );
    try {
      return await _signInOrLinkWithPhoneCredential(credential);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  /// When a user is already signed in (registration's "verify the phone you
  /// just gave us" step, run right after the email/password account is
  /// created) the verified phone credential is linked onto that account.
  /// Otherwise this is a phone-first sign-in and the credential is used to
  /// start a brand-new session.
  Future<AppUser> _signInOrLinkWithPhoneCredential(fb_auth.PhoneAuthCredential credential) async {
    final current = _auth.currentUser;
    final userCredential =
        current != null ? await current.linkWithCredential(credential) : await _auth.signInWithCredential(credential);
    final uid = userCredential.user!.uid;
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return _waitForUserDoc(uid);
    final user = AppUser.fromMap(snap.data()!);
    final updated = user.copyWith(phone: userCredential.user!.phoneNumber ?? user.phone);
    await _userDoc(uid).set(updated.toMap(), SetOptions(merge: true));
    return updated;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user dismissed the account picker
      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;
      final snap = await _userDoc(uid).get();
      if (!snap.exists) return _waitForUserDoc(uid);
      return AppUser.fromMap(snap.data()!);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
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
  Future<void> logout() async {
    // Sign out of Google too so the native account picker doesn't silently
    // re-offer the last Google account on the next "Continue with Google"
    // tap; harmless no-op if the session never used Google sign-in.
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

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
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('You must be signed in to do this.');
    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), code: e.code);
    }
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw AuthException('You must be signed in to do this.');
    }
    try {
      final credential = fb_auth.EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), code: e.code);
    }
  }

  @override
  Future<String> uploadProfilePhoto(File file) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('You must be signed in to do this.');
    try {
      final ref = FirebaseStorage.instance.ref('users/${user.uid}/profile.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to upload photo. Please try again.', code: e.code);
    }
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
      case 'invalid-verification-code':
        return 'That code is incorrect. Please check and try again.';
      case 'invalid-phone-number':
        return 'That phone number doesn\'t look right. Please check the country code and try again.';
      case 'session-expired':
      case 'code-expired':
        return 'This code has expired. Please request a new one.';
      case 'credential-already-in-use':
      case 'provider-already-linked':
      case 'account-exists-with-different-credential':
        return 'This phone number or Google account is already linked to another profile.';
      case 'quota-exceeded':
      case 'too-many-requests':
        return 'Too many attempts. Please wait a bit before trying again.';
      case 'sign_in_canceled':
        return 'Sign-in was cancelled.';
      case 'requires-recent-login':
        return 'For your security, please confirm your password to continue.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
