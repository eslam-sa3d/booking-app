import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/responsive_dialog.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersStream = ref.watch(membersRepositoryProvider).watchAll();
    final query = ref.watch(_searchQueryProvider).toLowerCase();

    return AdminPageScaffold(
      title: 'Members',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.isMobile ? double.infinity : 320,
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name or email'),
              onChanged: (v) => ref.read(_searchQueryProvider.notifier).state = v,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<AppUser>>(
            stream: membersStream,
            builder: (context, snapshot) {
              var members = snapshot.data ?? [];
              if (query.isNotEmpty) {
                members = members.where((m) => m.name.toLowerCase().contains(query) || m.email.toLowerCase().contains(query)).toList();
              }
              if (members.isEmpty) {
                return const Padding(padding: EdgeInsets.all(40), child: Text('No members found.'));
              }
              return Card(
                child: Column(
                  children: [
                    for (final member in members) _MemberRow(member: member),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.member});
  final AppUser member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(child: Text(member.initials)),
      title: Text(member.name, style: TextStyle(fontWeight: FontWeight.w700, decoration: member.suspended ? TextDecoration.lineThrough : null)),
      subtitle: Text('${member.email} · ${member.phone}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (member.role != 'customer')
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(label: Text(member.role), visualDensity: VisualDensity.compact),
            ),
          TextButton(
            onPressed: () => ref.read(membersRepositoryProvider).setSuspended(member.id, !member.suspended),
            child: Text(member.suspended ? 'Reactivate' : 'Suspend'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDetail(context, ref, member),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, AppUser member) {
    showDialog(
      context: context,
      builder: (_) => _MemberDetailDialog(member: member),
    );
  }
}

class _MemberDetailDialog extends ConsumerStatefulWidget {
  const _MemberDetailDialog({required this.member});
  final AppUser member;

  @override
  ConsumerState<_MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends ConsumerState<_MemberDetailDialog> {
  late AppUser _member = widget.member;
  late Future<List<dynamic>> _future = _load();

  Future<List<dynamic>> _load() {
    final repo = ref.read(membersRepositoryProvider);
    return Future.wait([
      repo.getFamilyMembers(_member.id),
      repo.getBookings(_member.id),
      repo.getPayments(_member.id),
    ]);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _editProfile() async {
    final result = await showDialog<AppUser>(
      context: context,
      builder: (_) => _EditProfileDialog(member: _member),
    );
    if (result != null) {
      setState(() => _member = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogShell(
      title: _member.name,
      desktopWidth: 480,
      desktopHeight: 520,
      content: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            final family = snapshot.data![0] as List<FamilyMember>;
            final bookings = snapshot.data![1] as List<Booking>;
            final payments = snapshot.data![2] as List<Payment>;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_member.email} · ${_member.phone}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text('Family members (${family.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  for (final f in family) _FamilyMemberTile(member: _member, familyMember: f, onChanged: _refresh),
                  const SizedBox(height: 16),
                  Text('Bookings (${bookings.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  for (final b in bookings.take(10)) Text('• ${b.participantName} — ${b.status.name}'),
                  const SizedBox(height: 16),
                  Text('Payment history (${payments.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  if (payments.isEmpty) const Text('No payments yet.', style: TextStyle(color: Colors.grey)),
                  for (final p in payments) _PaymentTile(payment: p),
                ],
              ),
            );
          },
        ),
      actions: [
        TextButton(onPressed: _editProfile, child: const Text('Edit profile')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});
  final Payment payment;

  static final _dateFmt = DateFormat('MMM d, yyyy');

  Color _statusColor() {
    switch (payment.status) {
      case PaymentStatus.succeeded:
        return Colors.teal;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.description.isEmpty ? '(no description)' : payment.description),
                Text(_dateFmt.format(payment.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${payment.amount.toStringAsFixed(2)} ${payment.currency}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(payment.status.name, style: TextStyle(fontSize: 11, color: _statusColor(), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberTile extends ConsumerWidget {
  const _FamilyMemberTile({required this.member, required this.familyMember, required this.onChanged});
  final AppUser member;
  final FamilyMember familyMember;
  final VoidCallback onChanged;

  Future<void> _awardBadge(BuildContext context, WidgetRef ref) async {
    final badge = await showDialog<SwimBadge>(
      context: context,
      builder: (_) => const _AwardBadgeDialog(),
    );
    if (badge == null) return;
    await ref.read(membersRepositoryProvider).awardBadge(member.id, familyMember.id, badge);
    onChanged();
  }

  Future<void> _addProgressNote(BuildContext context, WidgetRef ref) async {
    final note = await showDialog<ProgressNote>(
      context: context,
      builder: (_) => const _AddProgressNoteDialog(),
    );
    if (note == null) return;
    await ref.read(membersRepositoryProvider).addProgressNote(member.id, familyMember.id, note);
    onChanged();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${familyMember.name} (${familyMember.age}y)'),
                if (familyMember.badges.isNotEmpty)
                  Text('Badges: ${familyMember.badges.map((b) => b.title).join(', ')}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                if (familyMember.progressNotes.isNotEmpty)
                  Text('${familyMember.progressNotes.length} progress note(s)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, size: 18),
            tooltip: 'Award badge',
            onPressed: () => _awardBadge(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined, size: 18),
            tooltip: 'Add progress note',
            onPressed: () => _addProgressNote(context, ref),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({required this.member});
  final AppUser member;

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final _nameCtrl = TextEditingController(text: widget.member.name);
  late final _phoneCtrl = TextEditingController(text: widget.member.phone);
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    await ref.read(membersRepositoryProvider).updateProfile(widget.member.id, name: name, phone: phone);
    if (mounted) Navigator.of(context).pop(widget.member.copyWith(name: name, phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogShell(
      title: 'Edit profile',
      desktopWidth: 360,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? 'Saving…' : 'Save')),
      ],
    );
  }
}

class _AwardBadgeDialog extends StatefulWidget {
  const _AwardBadgeDialog();

  @override
  State<_AwardBadgeDialog> createState() => _AwardBadgeDialogState();
}

class _AwardBadgeDialogState extends State<_AwardBadgeDialog> {
  final _titleCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _iconCtrl = TextEditingController(text: 'emoji_events');

  void _save() {
    final badge = SwimBadge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      titleAr: _titleArCtrl.text.trim(),
      iconName: _iconCtrl.text.trim().isEmpty ? 'emoji_events' : _iconCtrl.text.trim(),
      earnedAt: DateTime.now(),
    );
    Navigator.of(context).pop(badge);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogShell(
      title: 'Award badge',
      desktopWidth: 360,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title (EN)')),
            const SizedBox(height: 12),
            TextFormField(controller: _titleArCtrl, decoration: const InputDecoration(labelText: 'Title (AR)')),
            const SizedBox(height: 12),
            TextFormField(controller: _iconCtrl, decoration: const InputDecoration(labelText: 'Icon name (Material, e.g. emoji_events)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Award')),
      ],
    );
  }
}

class _AddProgressNoteDialog extends StatefulWidget {
  const _AddProgressNoteDialog();

  @override
  State<_AddProgressNoteDialog> createState() => _AddProgressNoteDialogState();
}

class _AddProgressNoteDialogState extends State<_AddProgressNoteDialog> {
  final _noteCtrl = TextEditingController();
  final _noteArCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();

  void _save() {
    final note = ProgressNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      note: _noteCtrl.text.trim(),
      noteAr: _noteArCtrl.text.trim(),
      instructorName: _instructorCtrl.text.trim(),
      date: DateTime.now(),
    );
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogShell(
      title: 'Add progress note',
      desktopWidth: 360,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Note (EN)'), maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(controller: _noteArCtrl, decoration: const InputDecoration(labelText: 'Note (AR)'), maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(controller: _instructorCtrl, decoration: const InputDecoration(labelText: 'Instructor name')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
