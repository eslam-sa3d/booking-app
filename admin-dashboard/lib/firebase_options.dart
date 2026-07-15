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
    // Firebase's client SDKs validate the API key's shape before any
    // network call happens, so a trivially fake value like 'demo-api-key'
    // can crash native platforms at startup — this is a syntactically
    // valid-looking placeholder, never sent anywhere real since
    // main.dart always targets the emulator suite.
    apiKey: 'AIzaSyDEMO00000000000000000000000000000',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-swim-academy',
    authDomain: 'demo-swim-academy.firebaseapp.com',
    storageBucket: 'demo-swim-academy.appspot.com',
  );
}
