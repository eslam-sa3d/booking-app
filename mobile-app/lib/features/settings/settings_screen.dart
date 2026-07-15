import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_mode_provider.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/glass_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
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
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (context.mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel(l10n.settingsLanguage),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.settingsLanguageEnglish),
                  value: 'en',
                  groupValue: locale.languageCode,
                  onChanged: (v) => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                ),
                RadioListTile<String>(
                  title: Text(l10n.settingsLanguageArabic),
                  value: 'ar',
                  groupValue: locale.languageCode,
                  onChanged: (v) => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.settingsDarkMode),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.settingsDarkModeSystem),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.settingsDarkModeOff),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.settingsDarkModeOn),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.settingsSupport),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded),
                  title: Text(l10n.settingsWhatsapp),
                  onTap: () => _launch(Uri.parse('https://wa.me/966500000000')),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: Text(l10n.settingsFaq),
                  onTap: () => context.push('/settings/faq'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.settingsTerms),
                  onTap: () => _showStaticDoc(context, l10n.settingsTerms),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.settingsPrivacy),
                  onTap: () => _showStaticDoc(context, l10n.settingsPrivacy),
                ),
              ],
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text(l10n.settingsDeleteAccount, style: const TextStyle(color: Colors.red)),
                onTap: () => _confirmDeleteAccount(context, ref),
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

  void _showStaticDoc(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (ctx, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text(
                'Placeholder content — replace with the academy\'s actual legal text before release.',
              ),
            ],
          ),
        ),
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
