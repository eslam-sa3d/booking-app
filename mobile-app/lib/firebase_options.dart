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
    apiKey: 'AIzaSyD-wNicww3iJWMm5UZ19QB9whZ-ZA5wox8',
    appId: '1:691594727534:ios:05d858bf396b36bcdad67f',
    messagingSenderId: '691594727534',
    projectId: 'booking-app-36b8e',
    storageBucket: 'booking-app-36b8e.firebasestorage.app',
    iosBundleId: 'com.appbooking.appbooking',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8hj4VPuAiJuwPn2eKZNO5SaTAdxS701c',
    appId: '1:691594727534:android:5a59ea979abdaf67dad67f',
    messagingSenderId: '691594727534',
    projectId: 'booking-app-36b8e',
    storageBucket: 'booking-app-36b8e.firebasestorage.app',
  );
}
