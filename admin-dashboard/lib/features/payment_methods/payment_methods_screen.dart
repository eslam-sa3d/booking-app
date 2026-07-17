import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'payment_method_form_dialog.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsStream = ref.watch(paymentMethodsRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: 'Payment Methods',
      actions: [
        FilledButton.icon(
          onPressed: () => showPaymentMethodFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add payment method'),
        ),
      ],
      body: StreamBuilder<List<PaymentMethodConfig>>(
        stream: methodsStream,
        builder: (context, snapshot) {
          final methods = snapshot.data ?? [];
          if (methods.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No payment methods yet — add one to offer it at checkout.'),
            );
          }
          return Card(
            child: ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final reordered = [...methods];
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                ref.read(paymentMethodsRepositoryProvider).reorder(reordered);
              },
              children: [
                for (final method in methods)
                  ListTile(
                    key: ValueKey(method.id),
                    leading: Icon(Icons.payments_outlined, color: method.isActive ? Colors.teal : Colors.grey),
                    title: Row(
                      children: [
                        Text(method.nameEn, style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (!method.isActive) ...[
                          const SizedBox(width: 8),
                          const Text('Inactive', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ],
                    ),
                    subtitle: Text(method.nameAr),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: method.isActive,
                          onChanged: (v) => ref.read(paymentMethodsRepositoryProvider).update(method.copyWith(isActive: v)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showPaymentMethodFormDialog(context, ref, existing: method),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref.read(paymentMethodsRepositoryProvider).delete(method.id),
                        ),
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
