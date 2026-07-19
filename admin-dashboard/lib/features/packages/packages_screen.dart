import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'package_form_dialog.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesStream = ref.watch(packagesRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: 'Packages & Pricing',
      actions: [
        FilledButton.icon(
          onPressed: () => showPackageFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add package'),
        ),
      ],
      body: StreamBuilder<List<SwimPackage>>(
        stream: packagesStream,
        builder: (context, snapshot) {
          final packages = snapshot.data ?? [];
          if (packages.isEmpty) {
            return const Padding(padding: EdgeInsets.all(40), child: Text('No packages yet.'));
          }
          return Card(
            child: Column(
              children: [
                for (final pkg in packages)
                  ListTile(
                    title: Row(children: [
                      Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (pkg.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Popular', style: TextStyle(fontSize: 11, color: Colors.teal)),
                        ),
                      ],
                    ]),
                    subtitle: Text(
                      '${pkg.type.name} · ${pkg.sessionCount != null ? '${pkg.sessionCount} sessions' : 'unlimited'} · '
                      '${pkg.validityDays} days · ${pkg.price.toStringAsFixed(0)} EGP',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => showPackageFormDialog(context, ref, existing: pkg)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => ref.read(packagesRepositoryProvider).delete(pkg.id)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
