import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Placeholder Firebase Web config pointed at the local emulator suite
/// (project id `demo-swim-academy`, matching `backend/.firebaserc`).
///
/// Replace this file by running `flutterfire configure` from this
/// directory once a real Firebase project exists — that command
/// regenerates it with real API keys for dev/staging/production. Until
/// then every value below is a placeholder; they're never sent to a real
/// Firebase backend because `main.dart` always connects to the emulator
/// suite (see `useFirebaseEmulators`).
class DefaultFirebaseOptions {

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAnx-8VbXk25beYKjOwct3dEocHExQCE0Q',
    appId: '1:691594727534:web:4c1f555219e05bacdad67f',
    messagingSenderId: '691594727534',
    projectId: 'booking-app-36b8e',
    authDomain: 'booking-app-36b8e.firebaseapp.com',
    storageBucket: 'booking-app-36b8e.firebasestorage.app',
    measurementId: 'G-6VS0SNPN4F',
  );
}
