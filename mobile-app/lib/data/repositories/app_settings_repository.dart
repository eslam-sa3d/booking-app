import '../models/models.dart';

/// Reads the admin-editable `appSettings/config` singleton — brand colors,
/// FAQ copy, terms/privacy links, and support contact details. Public read,
/// admin-only write (see backend/firestore.rules); the mobile app never
/// writes to this document.
abstract class AppSettingsRepository {
  Future<AppSettings> getSettings();
}
