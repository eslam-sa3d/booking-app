import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/responsive_dialog.dart';
import '../auth/auth_controller.dart';
import '../../data/repositories/notifications_repository.dart';

const _segmentKeys = ['expiringPackageThisWeek', 'noBookingInLast30Days'];

String _segmentLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'expiringPackageThisWeek':
      return l10n.notificationsSegmentExpiringPackage;
    case 'noBookingInLast30Days':
      return l10n.notificationsSegmentNoBooking;
    default:
      return key;
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsStream = ref.watch(notificationsRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: l10n.notificationsTitle,
      actions: [
        FilledButton.icon(
          onPressed: () => _showComposeDialog(context, ref),
          icon: const Icon(Icons.campaign_outlined),
          label: Text(l10n.notificationsComposeBroadcast),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<NotificationDefinition>>(
            stream: notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // A failed read (e.g. a permission error) previously fell
                // through to "No broadcasts sent yet." — indistinguishable
                // from an empty list, and misleading when broadcasts had
                // actually been sent but couldn't be read back.
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.notificationsFailedToLoad(snapshot.error.toString())),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Padding(padding: const EdgeInsets.all(24), child: Text(l10n.notificationsEmptyState));
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

  String _targetLabel(AppLocalizations l10n) {
    switch (item.target) {
      case 'segment':
        return l10n.notificationsTargetSegmentDesc(_segmentLabel(l10n, item.targetSegment ?? ''));
      case 'user':
        return l10n.notificationsTargetSingleUser;
      default:
        return l10n.notificationsTargetAllUsers;
    }
  }

  String _statusLabel(AppLocalizations l10n) {
    switch (item.status) {
      case 'scheduled':
        return l10n.notificationsStatusScheduled;
      case 'draft':
        return l10n.notificationsStatusDraft;
      default:
        return l10n.notificationsStatusSent;
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
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.notificationsBodyTargetLine(item.body, _targetLabel(l10n))),
          if (item.status == 'scheduled' && item.scheduledFor != null)
            Text(l10n.notificationsScheduledFor(item.scheduledFor.toString()), style: const TextStyle(fontSize: 12)),
          if (item.status == 'sent')
            FutureBuilder<NotificationStats>(
              future: ref.read(notificationsRepositoryProvider).getStats(item.id),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l10n.notificationsFailedToLoadStats(snap.error.toString()),
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l10n.notificationsLoadingStats, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                }
                final stats = snap.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.notificationsDeliveryStats(stats.delivered, stats.read),
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
              _statusLabel(l10n),
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
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(authStateProvider).value;
    if (session == null) return;
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationsRequiredFieldsError)),
      );
      return;
    }
    if (_target == 'user' && _selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationsPickMemberError)),
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
    try {
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
    } catch (error) {
      // Without this, a failed write (e.g. a permission error) left the
      // dialog stuck on "Sending…" forever with no feedback — indistinguishable
      // from the notification silently not being saved.
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationsFailedToSend(error.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final membersAsync = ref.watch(membersRepositoryProvider).watchAll();

    return ResponsiveDialogShell(
      title: l10n.notificationsComposeBroadcast,
      desktopWidth: 480,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              TextFormField(controller: _titleCtrl, decoration: InputDecoration(labelText: l10n.notificationsTitleEnLabel)),
              const SizedBox(height: 12),
              TextFormField(controller: _titleArCtrl, decoration: InputDecoration(labelText: l10n.notificationsTitleArLabel)),
              const SizedBox(height: 12),
              TextFormField(controller: _bodyCtrl, decoration: InputDecoration(labelText: l10n.notificationsMessageEnLabel), maxLines: 2),
              const SizedBox(height: 12),
              TextFormField(controller: _bodyArCtrl, decoration: InputDecoration(labelText: l10n.notificationsMessageArLabel), maxLines: 2),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _target,
                decoration: InputDecoration(labelText: l10n.notificationsTargetLabel),
                items: [
                  DropdownMenuItem(value: 'all', child: Text(l10n.notificationsTargetAllUsers)),
                  DropdownMenuItem(value: 'segment', child: Text(l10n.notificationsTargetSegmentOption)),
                  DropdownMenuItem(value: 'user', child: Text(l10n.notificationsTargetSingleUser)),
                ],
                onChanged: (v) => setState(() => _target = v!),
              ),
              if (_target == 'segment') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _segment,
                  decoration: InputDecoration(labelText: l10n.notificationsTargetSegmentOption),
                  items: [
                    for (final key in _segmentKeys)
                      DropdownMenuItem(value: key, child: Text(_segmentLabel(l10n, key))),
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
                            labelText: l10n.notificationsSearchMemberLabel,
                            helperText: _selectedUser != null ? l10n.notificationsSelectedMember(_selectedUser!.name) : null,
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
                title: Text(l10n.notificationsScheduleForLater),
                subtitle: Text(l10n.notificationsScheduleOffHint),
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
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: _isSending ? null : _send,
          child: Text(_isSending ? l10n.notificationsSending : (_isScheduled ? l10n.notificationsScheduleButton : l10n.notificationsSendButton)),
        ),
      ],
    );
  }
}
