import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _googleLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    state.whenOrNull(
      data: (user) {
        if (user != null) context.go('/home');
      },
      error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString().replaceFirst('AuthException: ', ''))),
      ),
    );
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _googleLoading = true);
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    final state = ref.read(authControllerProvider);
    state.whenOrNull(
      data: (user) async {
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
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(l10n.authLoginTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(l10n.authLoginSubtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                Semantics(
                  label: l10n.authEmailOrPhone,
                  textField: true,
                  child: TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.authEmailOrPhone),
                    validator: (v) => Validators.required(v, l10n),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: l10n.authPassword,
                  textField: true,
                  child: TextFormField(
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
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(l10n.authForgotPassword),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  button: true,
                  label: l10n.authLogin,
                  child: AppButton(label: l10n.authLogin, isLoading: isLoading, onPressed: _submit),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  label: l10n.authGuestBrowse,
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: l10n.authGuestBrowse,
                      outlined: true,
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.authNoAccount),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(l10n.authRegister),
                    ),
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
