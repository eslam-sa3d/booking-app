import '../localization/generated/app_localizations.dart';

class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static String? required(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.authValidationRequired;
    return null;
  }

  static String? email(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.authValidationRequired;
    if (!_emailRegex.hasMatch(value.trim())) return l10n.authValidationEmail;
    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.authValidationRequired;
    if (value.length < 6) return l10n.authValidationPasswordLength;
    return null;
  }

  static String? confirmPassword(String? value, String original, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.authValidationRequired;
    if (value != original) return l10n.authValidationPasswordMatch;
    return null;
  }
}
