import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Flip to false once `flutterfire configure` has been run against a real
/// Firebase project and `firebase_options.dart` holds real credentials.
const bool kUseFirebaseEmulators = true;

/// The Android emulator's virtual network can't resolve the host
/// machine's `127.0.0.1` as itself — `10.0.2.2` is the documented alias
/// for it. iOS Simulator (and physical/desktop) share the host's network
/// namespace, so `127.0.0.1` works there directly.
String get _emulatorHost => defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1';

Future<void> bootstrapFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kUseFirebaseEmulators) {
    final host = _emulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
}
