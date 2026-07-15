import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import '../auth/auth_controller.dart';
import '../../data/repositories/notifications_repository.dart';

const _segmentLabels = {
  'expiringPackageThisWeek': 'Expiring package this week',
  'noBookingInLast30Days': 'No booking in last 30 days',
};

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
                    for (final item in items) _NotificationTile(item: item),
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

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item});
  final NotificationDefinition item;

  String _targetLabel() {
    switch (item.target) {
      case 'segment':
        return 'segment: ${_segmentLabels[item.targetSegment] ?? item.targetSegment}';
      case 'user':
        return 'single user';
      default:
        return 'all users';
    }
  }

  Color _statusColor(BuildContext context) {
    switch (item.status) {
      case 'scheduled':
        return Colors.blue;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${item.body} · target: ${_targetLabel()}'),
          if (item.status == 'scheduled' && item.scheduledFor != null)
            Text('Scheduled for ${item.scheduledFor}', style: const TextStyle(fontSize: 12)),
          if (item.status == 'sent')
            FutureBuilder<NotificationStats>(
              future: ref.read(notificationsRepositoryProvider).getStats(item.id),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Loading delivery stats…', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                }
                final stats = snap.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Delivered: ${stats.delivered} · Read: ${stats.read}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                );
              },
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(context)),
            ),
          ),
          const SizedBox(height: 4),
          Text(item.createdAt.toString().split(' ').first, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
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
  String _segment = 'expiringPackageThisWeek';
  AppUser? _selectedUser;
  bool _isScheduled = false;
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduledTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  bool _isSending = false;

  Future<void> _pickScheduledDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _scheduledDate = picked);
  }

  Future<void> _pickScheduledTime() async {
    final picked = await showTimePicker(context: context, initialTime: _scheduledTime);
    if (picked == null) return;
    setState(() => _scheduledTime = picked);
  }

  Future<void> _send() async {
    final session = ref.read(authStateProvider).value;
    if (session == null) return;
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title (EN) and Message (EN) are required.')),
      );
      return;
    }
    if (_target == 'user' && _selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a member to target.')),
      );
      return;
    }
    setState(() => _isSending = true);
    final scheduledFor = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );
    await ref.read(notificationsRepositoryProvider).compose(
          NotificationDefinition(
            id: '',
            type: 'promotion',
            title: _titleCtrl.text.trim(),
            titleAr: _titleArCtrl.text.trim(),
            body: _bodyCtrl.text.trim(),
            bodyAr: _bodyArCtrl.text.trim(),
            target: _target,
            targetUserId: _target == 'user' ? _selectedUser!.id : null,
            targetSegment: _target == 'segment' ? _segment : null,
            scheduledFor: _isScheduled ? scheduledFor : null,
            createdAt: DateTime.now(),
            createdBy: session.user.uid,
            status: _isScheduled ? 'scheduled' : 'sent',
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersRepositoryProvider).watchAll();

    return AlertDialog(
      title: const Text('Compose broadcast'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title (EN)')),
              const SizedBox(height: 12),
              TextFormField(controller: _titleArCtrl, decoration: const InputDecoration(labelText: 'Title (AR)')),
              const SizedBox(height: 12),
              TextFormField(controller: _bodyCtrl, decoration: const InputDecoration(labelText: 'Message (EN)'), maxLines: 2),
              const SizedBox(height: 12),
              TextFormField(controller: _bodyArCtrl, decoration: const InputDecoration(labelText: 'Message (AR)'), maxLines: 2),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _target,
                decoration: const InputDecoration(labelText: 'Target'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All users')),
                  DropdownMenuItem(value: 'segment', child: Text('Segment')),
                  DropdownMenuItem(value: 'user', child: Text('Single user')),
                ],
                onChanged: (v) => setState(() => _target = v!),
              ),
              if (_target == 'segment') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _segment,
                  decoration: const InputDecoration(labelText: 'Segment'),
                  items: [
                    for (final entry in _segmentLabels.entries)
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                  ],
                  onChanged: (v) => setState(() => _segment = v!),
                ),
              ],
              if (_target == 'user') ...[
                const SizedBox(height: 12),
                StreamBuilder<List<AppUser>>(
                  stream: membersAsync,
                  builder: (context, snapshot) {
                    final members = snapshot.data ?? [];
                    return Autocomplete<AppUser>(
                      displayStringForOption: (u) => '${u.name} (${u.email})',
                      optionsBuilder: (textEditingValue) {
                        final query = textEditingValue.text.trim().toLowerCase();
                        if (query.isEmpty) return const Iterable<AppUser>.empty();
                        return members.where(
                          (u) => u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query),
                        );
                      },
                      onSelected: (u) => setState(() => _selectedUser = u),
                      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Search member by name or email',
                            helperText: _selectedUser != null ? 'Selected: ${_selectedUser!.name}' : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Schedule for later'),
                subtitle: const Text('Off = send immediately'),
                value: _isScheduled,
                onChanged: (v) => setState(() => _isScheduled = v),
              ),
              if (_isScheduled)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickScheduledDate,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(_scheduledDate.toString().split(' ').first),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickScheduledTime,
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(_scheduledTime.format(context)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isSending ? null : _send,
          child: Text(_isSending ? 'Sending…' : (_isScheduled ? 'Schedule' : 'Send')),
        ),
      ],
    );
  }
}
