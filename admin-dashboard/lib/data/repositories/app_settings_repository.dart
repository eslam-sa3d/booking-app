import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('appSettings').doc('config');

  Stream<AppSettings> watch() {
    return _doc.snapshots().map((snap) => snap.exists ? AppSettings.fromMap(snap.data()!) : const AppSettings());
  }

  Future<void> save(AppSettings settings) => _doc.set(settings.toMap());
}
