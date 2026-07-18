import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/widgets/avatar_placeholder.dart';
import '../../core/widgets/app_button.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/glass_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // Plain showDialog/AlertDialog here, not the app's liquid-glass
    // showAppDialog wrapper — logout confirmation should look like a
    // standard Flutter dialog.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.profileLogoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.actionLogout)),
        ],
      ),
    );
    if (confirmed == true) {
      // logout() mutates authControllerProvider, which _AuthRefreshNotifier
      // (app_router.dart) also reacts to by notifying go_router's
      // refreshListenable — an explicit context.go() call right after races
      // that reaction and can crash the Navigator with a duplicate-page-key
      // assertion (the same class of bug fixed for the splash screen). This
      // screen already renders a "please log in" UI for a null user, so no
      // explicit navigation is needed — the state change alone rebuilds it.
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: GlassAppBar(title: Text(l10n.profileTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 64),
                const SizedBox(height: 16),
                Text(l10n.authLoginSubtitle, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                AppButton(label: l10n.authLogin, onPressed: () => context.push('/login')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              AvatarPlaceholder(initials: user.initials, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(user.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    Text(user.phone, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/profile/edit'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _MenuTile(icon: Icons.family_restroom_rounded, label: l10n.profileFamilyMembers, onTap: () => context.push('/family')),
          _MenuTile(icon: Icons.card_membership_rounded, label: l10n.profileMyPackages, onTap: () => context.push('/packages')),
          _MenuTile(icon: Icons.receipt_long_rounded, label: l10n.profilePaymentHistory, onTap: () => context.push('/payment-history')),
          _MenuTile(icon: Icons.notifications_outlined, label: l10n.notificationsTitle, onTap: () => context.push('/notifications')),
          _MenuTile(icon: Icons.settings_outlined, label: l10n.profileSettings, onTap: () => context.push('/settings')),
          _MenuTile(icon: Icons.support_agent_rounded, label: l10n.profileSupport, onTap: () => context.push('/settings/faq')),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: l10n.actionLogout,
            color: Theme.of(context).colorScheme.error,
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
