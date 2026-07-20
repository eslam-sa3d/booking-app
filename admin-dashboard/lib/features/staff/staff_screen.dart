import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/responsive_dialog.dart';
import '../auth/auth_controller.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  String _roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'admin':
        return l10n.staffRoleAdmin;
      case 'staff':
        return l10n.staffRoleStaff;
      default:
        return role;
    }
  }

  Future<void> _confirmRevoke(BuildContext context, WidgetRef ref, AppUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.staffRevokeDialogTitle),
        content: Text(l10n.staffRevokeDialogContent(user.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.staffRevokeButton)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(staffRepositoryProvider).assignRole(targetUid: user.id, role: 'customer');
    } catch (error) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.staffRevokeFailedMessage(error.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authStateProvider).value;
    final staffStream = ref.watch(staffRepositoryProvider).watchStaffAndAdmins();

    return AdminPageScaffold(
      title: l10n.staffTitle,
      actions: [
        if (session?.isAdmin == true)
          FilledButton.icon(
            onPressed: () => _showPromoteDialog(context, ref),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(l10n.staffGrantAccessButton),
          ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session?.isAdmin != true)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
              child: Text(l10n.staffAdminOnlyNotice, style: const TextStyle(fontSize: 12)),
            ),
          StreamBuilder<List<AppUser>>(
            stream: staffStream,
            builder: (context, snapshot) {
              final staff = snapshot.data ?? [];
              if (staff.isEmpty) {
                return Padding(padding: const EdgeInsets.all(24), child: Text(l10n.staffEmptyState));
              }
              return Card(
                child: Column(
                  children: [
                    for (final user in staff)
                      ListTile(
                        leading: CircleAvatar(child: Text(user.initials)),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(label: Text(_roleLabel(l10n, user.role)), visualDensity: VisualDensity.compact),
                            if (session?.isAdmin == true && user.id != session?.user.uid)
                              IconButton(
                                icon: const Icon(Icons.person_remove_outlined),
                                tooltip: l10n.staffRevokeTooltip,
                                onPressed: () => _confirmRevoke(context, ref, user),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPromoteDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final uidCtrl = TextEditingController();
    String role = 'staff';
    bool isSaving = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => ResponsiveDialogShell(
          title: l10n.staffGrantDialogTitle,
          desktopWidth: 400,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: uidCtrl, decoration: InputDecoration(labelText: l10n.staffUserUidLabel)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(labelText: l10n.staffRoleLabel),
                  items: [
                    DropdownMenuItem(value: 'staff', child: Text(l10n.staffRoleStaff)),
                    DropdownMenuItem(value: 'admin', child: Text(l10n.staffRoleAdmin)),
                  ],
                  onChanged: (v) => setState(() => role = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setState(() => isSaving = true);
                      try {
                        await ref.read(staffRepositoryProvider).assignRole(targetUid: uidCtrl.text.trim(), role: role);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (error) {
                        setState(() => isSaving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.staffGrantFailedMessage(error.toString()))));
                        }
                      }
                    },
              child: Text(isSaving ? l10n.staffGranting : l10n.staffGrantButton),
            ),
          ],
        ),
      ),
    );
  }
}
