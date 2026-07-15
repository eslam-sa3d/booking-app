import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import 'auth_controller.dart';
import '../../core/widgets/glass_app_bar.dart';

/// Best-effort E.164 normalization for Firebase Phone Auth, which requires
/// a leading '+' and country code. This app targets Saudi Arabia (SAR
/// pricing used throughout the booking flow) so a bare local number
/// defaults to +966; a full country-code picker is out of scope here.
String _toE164(String rawPhone) {
  final trimmed = rawPhone.trim();
  if (trimmed.startsWith('+')) return '+${trimmed.substring(1).replaceAll(RegExp(r'\D'), '')}';
  final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
  final national = digitsOnly.startsWith('0') ? digitsOnly.substring(1) : digitsOnly;
  return '+966$national';
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _googleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    state.whenOrNull(
      data: (user) {
        // The account was just created with email/password; route to the
        // OTP screen to verify the phone number as a follow-up step
        // (real Firebase Phone Auth SMS — see OtpScreen) before letting
        // the user into the app.
        if (user != null) {
          context.push('/otp?destination=${Uri.encodeComponent(_toE164(_phoneController.text))}');
        }
      },
      error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString().replaceFirst('AuthException: ', ''))),
      ),
    );
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _googleLoading = true);
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    final state = ref.read(authControllerProvider);
    state.whenOrNull(
      data: (user) async {
        // Google already proves the user's identity — no separate phone
        // OTP step needed, unlike the email/password path above.
        if (user != null) {
          await ref.read(analyticsServiceProvider).logLogin(method: 'google');
          if (mounted) context.go('/home');
        }
      },
      error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString().replaceFirst('AuthException: ', ''))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: GlassAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.authRegisterTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(l10n.authRegisterSubtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 28),
                Semantics(
                  label: l10n.authFullName,
                  textField: true,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: l10n.authFullName),
                    validator: (v) => Validators.required(v, l10n),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: l10n.authEmail,
                  textField: true,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.authEmail),
                    validator: (v) => Validators.email(v, l10n),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: l10n.authPhone,
                  textField: true,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l10n.authPhone),
                    validator: (v) => Validators.required(v, l10n),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: l10n.authPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => Validators.password(v, l10n),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: InputDecoration(labelText: l10n.authConfirmPassword),
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text, l10n),
                ),
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  label: l10n.authRegister,
                  child: AppButton(label: l10n.authRegister, isLoading: authState.isLoading, onPressed: _submit),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.authAgreeToTerms,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.authOrContinueWith,
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                  ],
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: l10n.authContinueWithGoogle,
                  child: AppButton(
                    label: l10n.authContinueWithGoogle,
                    icon: Icons.g_mobiledata_rounded,
                    outlined: true,
                    isLoading: _googleLoading,
                    onPressed: _continueWithGoogle,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.authAlreadyHaveAccount),
                    TextButton(onPressed: () => context.pop(), child: Text(l10n.authLogin)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
