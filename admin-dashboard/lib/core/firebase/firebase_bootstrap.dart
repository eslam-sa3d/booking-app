import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../firebase_options.dart';

/// Flip to false once `flutterfire configure` has been run against a real
/// Firebase project and `firebase_options.dart` holds real credentials.
const bool kUseFirebaseEmulators = false;

Future<void> bootstrapFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  // Some corporate proxies/security agents break the Firestore Web SDK's
  // default streaming (WebChannel) transport — requests then hang forever
  // with no response and no error, rather than failing cleanly. Auto-
  // detecting long-polling falls back to plain HTTP requests when
  // streaming isn't usable, without the overhead of forcing it when it is.
  FirebaseFirestore.instance.settings = const Settings(
    webExperimentalAutoDetectLongPolling: true,
  );

  if (kUseFirebaseEmulators) {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    await FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
    FirebaseFunctions.instance.useFunctionsEmulator('127.0.0.1', 5001);
  }
}
