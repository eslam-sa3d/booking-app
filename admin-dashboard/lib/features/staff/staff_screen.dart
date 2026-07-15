import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/responsive_dialog.dart';
import '../auth/auth_controller.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authStateProvider).value;
    final staffStream = ref.watch(staffRepositoryProvider).watchStaffAndAdmins();

    return AdminPageScaffold(
      title: 'Staff Accounts & Permissions',
      actions: [
        if (session?.isAdmin == true)
          FilledButton.icon(
            onPressed: () => _showPromoteDialog(context, ref),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Grant access'),
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
              child: const Text('Only admins can grant or revoke dashboard access.', style: TextStyle(fontSize: 12)),
            ),
          StreamBuilder<List<AppUser>>(
            stream: staffStream,
            builder: (context, snapshot) {
              final staff = snapshot.data ?? [];
              if (staff.isEmpty) {
                return const Padding(padding: EdgeInsets.all(24), child: Text('No staff/admin accounts yet.'));
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
                            Chip(label: Text(user.role), visualDensity: VisualDensity.compact),
                            if (session?.isAdmin == true && user.id != session?.user.uid)
                              IconButton(
                                icon: const Icon(Icons.person_remove_outlined),
                                tooltip: 'Revoke to customer',
                                onPressed: () => ref.read(staffRepositoryProvider).assignRole(targetUid: user.id, role: 'customer'),
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
    final uidCtrl = TextEditingController();
    String role = 'staff';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => ResponsiveDialogShell(
          title: 'Grant dashboard access',
          desktopWidth: 400,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: uidCtrl, decoration: const InputDecoration(labelText: 'User UID (from Members screen / Auth)')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (v) => setState(() => role = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                await ref.read(staffRepositoryProvider).assignRole(targetUid: uidCtrl.text.trim(), role: role);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Grant'),
            ),
          ],
        ),
      ),
    );
  }
}
