import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Placeholder Firebase config pointed at the local emulator suite
/// (project id `demo-swim-academy`, matching `backend/.firebaserc`).
///
/// Replace this file by running `flutterfire configure` from this
/// directory once a real Firebase project exists. Until then every value
/// below is a placeholder; they're never sent to a real Firebase backend
/// because `main.dart` always connects to the emulator suite (see
/// `useFirebaseEmulators`).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    // Firebase's client SDKs validate the API key's shape (must look like
    // a real Google API key) before any network call even happens, so a
    // trivially fake value like 'demo-api-key' crashes iOS at startup —
    // this is a syntactically valid-looking placeholder, never sent
    // anywhere real since main.dart always targets the emulator suite.
    apiKey: 'AIzaSyDEMO00000000000000000000000000000',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-swim-academy',
    iosBundleId: 'com.swimacademy.bookingApp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    // Firebase's client SDKs validate the API key's shape (must look like
    // a real Google API key) before any network call even happens, so a
    // trivially fake value like 'demo-api-key' crashes iOS at startup —
    // this is a syntactically valid-looking placeholder, never sent
    // anywhere real since main.dart always targets the emulator suite.
    apiKey: 'AIzaSyDEMO00000000000000000000000000000',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-swim-academy',
  );
}
