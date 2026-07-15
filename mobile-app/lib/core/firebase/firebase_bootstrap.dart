import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Flip to false once `flutterfire configure` has been run against a real
/// Firebase project and `firebase_options.dart` holds real credentials.
const bool kUseFirebaseEmulators = false;

/// Set via `--dart-define=EMULATOR_HOST=<mac-lan-ip>` when running on a
/// physical device, which can't reach the host machine via `127.0.0.1`/
/// `10.0.2.2` — those only resolve for simulators/emulators sharing (or
/// aliasing) the host's own network namespace. Find your Mac's LAN IP with
/// `ipconfig getifaddr en0`, make sure the phone is on the same Wi-Fi, and
/// `backend/firebase.json` must bind emulators to `0.0.0.0` (already set).
const String _emulatorHostOverride = String.fromEnvironment('EMULATOR_HOST');

/// The Android emulator's virtual network can't resolve the host
/// machine's `127.0.0.1` as itself — `10.0.2.2` is the documented alias
/// for it. iOS Simulator (and physical/desktop) share the host's network
/// namespace, so `127.0.0.1` works there directly.
String get _emulatorHost {
  if (_emulatorHostOverride.isNotEmpty) return _emulatorHostOverride;
  return defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1';
}

Future<void> bootstrapFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kUseFirebaseEmulators) {
    final host = _emulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
}
