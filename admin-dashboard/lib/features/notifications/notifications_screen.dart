import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import '../auth/auth_controller.dart';
import '../../data/repositories/notifications_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsStream = ref.watch(notificationsRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: 'Notification Center',
      actions: [
        FilledButton.icon(
          onPressed: () => _showComposeDialog(context, ref),
          icon: const Icon(Icons.campaign_outlined),
          label: const Text('Compose broadcast'),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Delivery is currently logged only (dispatchNotification is a stub) — push/inbox fan-out ships in the next backend pass. '
              'System-triggered notifications (booking confirmed, waitlist promoted) already work end-to-end.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<NotificationDefinition>>(
            stream: notificationsStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Padding(padding: EdgeInsets.all(24), child: Text('No broadcasts sent yet.'));
              }
              return Card(
                child: Column(
                  children: [
                    for (final item in items)
                      ListTile(
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${item.body} · target: ${item.target}'),
                        trailing: Text(item.createdAt.toString().split(' ').first),
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

  void _showComposeDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => const _ComposeDialog());
  }
}

class _ComposeDialog extends ConsumerStatefulWidget {
  const _ComposeDialog();

  @override
  ConsumerState<_ComposeDialog> createState() => _ComposeDialogState();
}

class _ComposeDialogState extends ConsumerState<_ComposeDialog> {
  final _titleCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _bodyArCtrl = TextEditingController();
  String _target = 'all';
  bool _isSending = false;

  Future<void> _send() async {
    final session = ref.read(authStateProvider).value;
    if (session == null) return;
    setState(() => _isSending = true);
    await ref.read(notificationsRepositoryProvider).compose(
          NotificationDefinition(
            id: '',
            type: 'promotion',
            title: _titleCtrl.text.trim(),
            titleAr: _titleArCtrl.text.trim(),
            body: _bodyCtrl.text.trim(),
            bodyAr: _bodyArCtrl.text.trim(),
            target: _target,
            createdAt: DateTime.now(),
            createdBy: session.user.uid,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compose broadcast'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title (EN)')),
            const SizedBox(height: 12),
            TextFormField(controller: _titleArCtrl, decoration: const InputDecoration(labelText: 'Title (AR)')),
            const SizedBox(height: 12),
            TextFormField(controller: _bodyCtrl, decoration: const InputDecoration(labelText: 'Message (EN)'), maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(controller: _bodyArCtrl, decoration: const InputDecoration(labelText: 'Message (AR)'), maxLines: 2),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _target,
              decoration: const InputDecoration(labelText: 'Target'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All users')),
                DropdownMenuItem(value: 'segment', child: Text('Segment (not yet implemented)')),
              ],
              onChanged: (v) => setState(() => _target = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _isSending ? null : _send, child: Text(_isSending ? 'Sending…' : 'Send')),
      ],
    );
  }
}
