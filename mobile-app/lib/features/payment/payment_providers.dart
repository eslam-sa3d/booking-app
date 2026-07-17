import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';

/// Active, admin-configured payment methods to offer at checkout — see
/// the admin dashboard's Payment Methods screen for where these are managed.
final activePaymentMethodsProvider = FutureProvider<List<PaymentMethodConfig>>((ref) {
  return ref.watch(paymentRepositoryProvider).getActivePaymentMethods();
});
