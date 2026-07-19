import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/biometric_lock_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_mode_provider.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/glass_app_bar.dart';
import 'app_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDeleteAccount),
        content: Text(l10n.settingsDeleteAccountConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // deleteAccount() mutates authControllerProvider, which
      // _AuthRefreshNotifier (app_router.dart) also reacts to by notifying
      // go_router's refreshListenable — an explicit context.go() call right
      // after races that reaction and can crash the Navigator with a
      // duplicate-page-key assertion (the same class of bug fixed for the
      // splash screen). This screen already hides its account-only sections
      // for a null user, so no explicit navigation is needed.
      await ref.read(authControllerProvider.notifier).deleteAccount();
    }
  }

  Future<void> _updateNotificationPrefs(
    WidgetRef ref,
    AppUser user, {
    bool? reminders,
    bool? promotions,
    bool? announcements,
  }) {
    final prefs = user.notificationPreferences.copyWith(
      reminders: reminders,
      promotions: promotions,
      announcements: announcements,
    );
    return ref.read(authControllerProvider.notifier).updateProfile(user.copyWith(notificationPreferences: prefs));
  }

  Future<void> _openWhatsapp(BuildContext context, String? number, bool isArabic) async {
    if (number == null || number.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'الدعم عبر واتساب غير متاح حالياً.' : 'WhatsApp support isn\'t available yet.')),
      );
      return;
    }
    await _launch(Uri.parse('https://wa.me/$number'));
  }

  Future<void> _openEmail(BuildContext context, String? email, bool isArabic) async {
    if (email == null || email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'الدعم عبر البريد الإلكتروني غير متاح حالياً.' : 'Email support isn\'t available yet.')),
      );
      return;
    }
    await _launch(Uri(scheme: 'mailto', path: email));
  }

  Future<void> _openLegalDoc(BuildContext context, String? url, String title, bool isArabic) async {
    if (url != null && url.trim().isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await _launch(uri);
        return;
      }
    }
    if (!context.mounted) return;
    showAppBottomSheet(
      context,
      isScrollControlled: true,
      useGlass: false,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        expand: false,
        builder: (ctx, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(isArabic ? 'لم يتم نشر هذا المحتوى بعد.' : 'This content hasn\'t been published yet.'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isArabic = ref.watch(isArabicProvider);
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);
    final appSettings = ref.watch(appSettingsFutureProvider).valueOrNull;
    final biometricLockEnabled = ref.watch(biometricLockEnabledProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel(l10n.settingsLanguage),
          Card(
            child: RadioGroup<String>(
              groupValue: locale.languageCode,
              onChanged: (v) {
                if (v != null) ref.read(localeProvider.notifier).setLocale(Locale(v));
              },
              child: Column(
                children: [
                  RadioListTile<String>(title: Text(l10n.settingsLanguageEnglish), value: 'en'),
                  RadioListTile<String>(title: Text(l10n.settingsLanguageArabic), value: 'ar'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.settingsDarkMode),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (v) {
                if (v != null) ref.read(themeModeProvider.notifier).setMode(v);
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(title: Text(l10n.settingsDarkModeSystem), value: ThemeMode.system),
                  RadioListTile<ThemeMode>(title: Text(l10n.settingsDarkModeOff), value: ThemeMode.light),
                  RadioListTile<ThemeMode>(title: Text(l10n.settingsDarkModeOn), value: ThemeMode.dark),
                ],
              ),
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 20),
            _SectionLabel(l10n.settingsBiometricLock),
            Card(
              child: SwitchListTile(
                title: Text(l10n.settingsBiometricLock),
                subtitle: Text(l10n.settingsBiometricLockSubtitle),
                value: biometricLockEnabled,
                onChanged: (v) => ref.read(biometricLockEnabledProvider.notifier).setEnabled(v),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(l10n.settingsNotifications),
            Card(
              child: Column(
                children: [
                  Semantics(
                    label: isArabic ? 'تبديل تذكيرات الحصص' : 'Toggle session reminders',
                    child: SwitchListTile(
                      title: Text(isArabic ? 'تذكيرات الحصص' : 'Session reminders'),
                      value: user.notificationPreferences.reminders,
                      onChanged: (v) => _updateNotificationPrefs(ref, user, reminders: v),
                    ),
                  ),
                  Semantics(
                    label: isArabic ? 'تبديل العروض والتخفيضات' : 'Toggle promotions and offers',
                    child: SwitchListTile(
                      title: Text(isArabic ? 'العروض والتخفيضات' : 'Promotions & offers'),
                      value: user.notificationPreferences.promotions,
                      onChanged: (v) => _updateNotificationPrefs(ref, user, promotions: v),
                    ),
                  ),
                  Semantics(
                    label: isArabic ? 'تبديل الإعلانات' : 'Toggle announcements',
                    child: SwitchListTile(
                      title: Text(isArabic ? 'الإعلانات' : 'Announcements'),
                      value: user.notificationPreferences.announcements,
                      onChanged: (v) => _updateNotificationPrefs(ref, user, announcements: v),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SectionLabel(l10n.settingsSupport),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded),
                  title: Text(l10n.settingsWhatsapp),
                  onTap: () => _openWhatsapp(context, appSettings?.whatsappNumber, isArabic),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(isArabic ? 'راسلنا عبر البريد الإلكتروني' : 'Email support'),
                  subtitle: appSettings?.contactEmail != null ? Text(appSettings!.contactEmail!) : null,
                  onTap: () => _openEmail(context, appSettings?.contactEmail, isArabic),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: Text(l10n.settingsFaq),
                  onTap: () => context.push('/settings/faq'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.settingsTerms),
                  onTap: () => _openLegalDoc(context, appSettings?.termsUrl, l10n.settingsTerms, isArabic),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.settingsPrivacy),
                  onTap: () => _openLegalDoc(context, appSettings?.privacyUrl, l10n.settingsPrivacy, isArabic),
                ),
              ],
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Semantics(
                button: true,
                label: l10n.settingsDeleteAccount,
                child: ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: Text(l10n.settingsDeleteAccount, style: const TextStyle(color: Colors.red)),
                  onTap: () => _confirmDeleteAccount(context, ref),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Center(
            child: Text(
              l10n.settingsAppVersion('1.0.0'),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}
