import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/avatar_placeholder.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/models.dart';
import 'family_providers.dart';
import '../../core/widgets/glass_app_bar.dart';

class FamilyMembersScreen extends ConsumerWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final membersAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.familyTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/family/add'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.familyAdd),
      ),
      body: membersAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(onRetry: () => ref.invalidate(familyMembersProvider)),
        data: (members) {
          if (members.isEmpty) {
            return EmptyState(icon: Icons.family_restroom_rounded, message: l10n.familyEmpty);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: members.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: AvatarPlaceholder(
                    initials: member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    colors: member.gender == Gender.female
                        ? const [Color(0xFFDB2777), Color(0xFF7C3AED)]
                        : null,
                  ),
                  title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${l10n.familyAgeYears(member.age)} · ${l10n.familyLevelLabel(member.swimmingLevel)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/family/edit/${member.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          await ref.read(familyRepositoryProvider).deleteFamilyMember(member.userId, member.id);
                          ref.invalidate(familyMembersProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
