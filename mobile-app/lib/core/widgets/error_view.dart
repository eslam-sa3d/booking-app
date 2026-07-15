import 'package:flutter/material.dart';

import '../localization/generated/app_localizations.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message ?? l10n.errorGeneric, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(label: l10n.actionRetry, outlined: true, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
