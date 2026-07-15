import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminSession {
  final User user;
  final String role; // 'customer' | 'staff' | 'admin'
  const AdminSession({required this.user, required this.role});

  bool get isStaffOrAdmin => role == 'staff' || role == 'admin';
  bool get isAdmin => role == 'admin';
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// Streams the signed-in user together with their role custom claim,
/// re-evaluating whenever Firebase Auth's own state changes. `null` means
/// signed out; a session with `isStaffOrAdmin == false` means a customer
/// account tried to sign in here — the UI must reject that, not just hide it.
final authStateProvider = StreamProvider<AdminSession?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  await for (final user in auth.authStateChanges()) {
    if (user == null) {
      yield null;
      continue;
    }
    final tokenResult = await user.getIdTokenResult(true);
    final role = tokenResult.claims?['role'] as String? ?? 'customer';
    yield AdminSession(user: user, role: role);
  }
});

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<String?> login({required String email, required String password}) async {
    final auth = ref.read(firebaseAuthProvider);
    try {
      final credential = await auth.signInWithEmailAndPassword(email: email, password: password);
      final tokenResult = await credential.user!.getIdTokenResult(true);
      final role = tokenResult.claims?['role'] as String? ?? 'customer';
      if (role != 'staff' && role != 'admin') {
        await auth.signOut();
        return 'This account does not have dashboard access.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed.';
    }
  }

  Future<void> logout() => ref.read(firebaseAuthProvider).signOut();
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));
