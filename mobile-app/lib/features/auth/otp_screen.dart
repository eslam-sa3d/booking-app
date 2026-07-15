import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../data/models/models.dart';
import 'auth_controller.dart';

/// Verifies the phone number the user gave during registration via real
/// Firebase Phone Auth (an SMS with a 6-digit code, sent by
/// [AuthRepository.sendOtp]). The account itself was already created with
/// email/password before landing here — this screen links the verified
/// phone number onto that account rather than starting a new session.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.destination});

  /// Phone number in E.164 format (e.g. "+9665XXXXXXXX").
  final String destination;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _isVerifying = false;
  bool _isSending = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    setState(() {
      _isSending = true;
      _error = null;
    });
    ref.read(authRepositoryProvider).sendOtp(
          phoneNumber: widget.destination,
          onCodeSent: (verificationId) {
            if (!mounted) return;
            setState(() {
              _verificationId = verificationId;
              _isSending = false;
            });
          },
          onAutoVerified: (user) => _handleVerified(user),
          onFailed: (message) {
            if (!mounted) return;
            setState(() {
              _isSending = false;
              _error = message;
            });
          },
        );
  }

  Future<void> _handleVerified(AppUser user) async {
    ref.read(authControllerProvider.notifier).setUser(user);
    await ref.read(analyticsServiceProvider).logRegistration(method: 'phone');
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context)!;
    final verificationId = _verificationId;
    if (verificationId == null) {
      setState(() => _error = l10n.errorGeneric);
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      final user = await ref.read(authRepositoryProvider).verifyOtp(
            verificationId: verificationId,
            code: _codeController.text,
          );
      await _handleVerified(user);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
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
              Semantics(
                label: l10n.authOtpTitle,
                textField: true,
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  enabled: !_isSending,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: _error,
                    hintText: _isSending ? '••••••' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: l10n.authOtpVerify,
                child: AppButton(
                  label: l10n.authOtpVerify,
                  isLoading: _isVerifying,
                  onPressed: _isSending ? null : _verify,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Semantics(
                  button: true,
                  label: l10n.authOtpResend,
                  child: TextButton(
                    onPressed: _isSending ? null : _sendCode,
                    child: Text(l10n.authOtpResend),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
