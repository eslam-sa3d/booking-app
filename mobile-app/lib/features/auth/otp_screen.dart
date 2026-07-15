import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/glass_app_bar.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.destination});

  final String destination;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final ok = await ref.read(authRepositoryProvider).verifyOtp(
          destination: widget.destination,
          code: _codeController.text,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      context.go('/home');
    } else {
      setState(() => _error = l10n.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: GlassAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.authOtpTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                l10n.authOtpSubtitle(widget.destination),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.w700),
                decoration: InputDecoration(counterText: '', errorText: _error),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: l10n.authOtpVerify, isLoading: _isLoading, onPressed: _verify),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => ref.read(authRepositoryProvider).sendOtp(destination: widget.destination),
                  child: Text(l10n.authOtpResend),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
