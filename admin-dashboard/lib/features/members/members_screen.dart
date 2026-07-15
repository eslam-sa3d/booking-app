import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';

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
            width: 320,
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
      builder: (_) => AlertDialog(
        title: Text(member.name),
        content: SizedBox(
          width: 420,
          child: FutureBuilder(
            future: Future.wait([
              ref.read(membersRepositoryProvider).getFamilyMembers(member.id),
              ref.read(membersRepositoryProvider).getBookings(member.id),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              final family = snapshot.data![0] as List<FamilyMember>;
              final bookings = snapshot.data![1] as List<Booking>;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Family members (${family.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                    for (final f in family) Text('• ${f.name} (${f.age}y)'),
                    const SizedBox(height: 16),
                    Text('Bookings (${bookings.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                    for (final b in bookings.take(10)) Text('• ${b.participantName} — ${b.status.name}'),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}
