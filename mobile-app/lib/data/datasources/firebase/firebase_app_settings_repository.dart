import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../models/models.dart';
import '../../repositories/app_settings_repository.dart';

class FirebaseAppSettingsRepository implements AppSettingsRepository {
  FirebaseAppSettingsRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<AppSettings> getSettings() async {
    final snap = await _db.collection('appSettings').doc('config').get();
    final data = snap.data();
    if (data == null) return const AppSettings();
    return AppSettings.fromMap(data);
  }
}

/// Mirrors the `*RepositoryProvider`s in core/providers/repository_providers.dart
/// (kept here instead, since AppSettings was added after that file — wire
/// this into repository_providers.dart and test/test_overrides.dart's mock
/// list the next time that file is touched, alongside a MockAppSettingsRepository
/// in data/datasources/mock/ for hermetic widget tests).
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>(
  (ref) => FirebaseAppSettingsRepository(ref.watch(firebaseFirestoreProvider)),
);
