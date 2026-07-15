import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

import 'audited_write.dart';

class AppSettingsRepository with AuditedWrite {
  AppSettingsRepository(this._db, this.auth, this.functions);
  final FirebaseFirestore _db;
  @override
  final FirebaseAuth auth;
  @override
  final FirebaseFunctions functions;

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('appSettings').doc('config');

  Stream<AppSettings> watch() {
    return _doc.snapshots().map((snap) => snap.exists ? AppSettings.fromMap(snap.data()!) : const AppSettings());
  }

  Future<void> save(AppSettings settings) => _doc.set(tagged(settings.toMap()));
}
