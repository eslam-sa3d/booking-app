import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../localization/generated/app_localizations.dart';
import '../providers/biometric_lock_provider.dart';
import '../../features/auth/auth_controller.dart';

/// Wraps the whole app (see app.dart) and, when the user has opted into
/// Face ID/biometric lock in Settings, shows an opaque lock screen over
/// everything on cold start and whenever the app resumes from the
/// background — until the user re-authenticates. Purely a UI gate on top
/// of the existing Firebase session; no credentials are stored or re-sent.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  bool _locked = false;

  // Showing (and dismissing) the native biometric/PIN prompt itself pauses
  // and resumes the app's own Activity/Scene — didChangeAppLifecycleState
  // fires `resumed` for that, indistinguishable from the user genuinely
  // switching back in from another app. Without this guard, a successful
  // unlock's own resume event immediately re-locks the app, which re-opens
  // the prompt, which resumes again, forever — the "asks every second"
  // loop. While true (plus a short grace period after authenticate()
  // settles, since the OS's resume event can arrive slightly after the
  // Future resolves), resume events are ignored.
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _lockIfEligible();
  }

  void _lockIfEligible() {
    if (_authenticating) return;
    final enabled = ref.read(biometricLockEnabledProvider);
    final loggedIn = ref.read(currentUserProvider) != null;
    if (enabled && loggedIn && !_locked) setState(() => _locked = true);
  }

  Future<void> _unlock() async {
    final auth = ref.read(localAuthProvider);
    final reason = AppLocalizations.of(context)?.appLockSubtitle ?? "Verify it's you to continue";
    _authenticating = true;
    try {
      final supported = await auth.isDeviceSupported();
      if (!supported) {
        if (mounted) setState(() => _locked = false);
        return;
      }
      final didAuthenticate = await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (didAuthenticate && mounted) setState(() => _locked = false);
    } catch (_) {
      // Best-effort — the lock screen stays up and the user can retry.
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _authenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Covers cold start with an already-persisted Firebase session:
    // currentUserProvider resolves from null to a user sometime after this
    // widget's first build, independently of the didChangeAppLifecycleState
    // resume check above (which only fires on a later background/foreground
    // cycle, not on the initial launch).
    ref.listen(currentUserProvider, (previous, next) {
      if (previous == null && next != null && ref.read(biometricLockEnabledProvider)) {
        setState(() => _locked = true);
      }
    });

    return Stack(
      children: [
        widget.child,
        if (_locked) _LockScreen(onUnlock: _unlock),
      ],
    );
  }
}

class _LockScreen extends StatefulWidget {
  const _LockScreen({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onUnlock());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fingerprint_rounded, size: 72),
                const SizedBox(height: 20),
                Text(l10n?.appLockTitle ?? 'App locked', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(l10n?.appLockSubtitle ?? "Verify it's you to continue", textAlign: TextAlign.center),
                const SizedBox(height: 28),
                FilledButton(onPressed: widget.onUnlock, child: Text(l10n?.appLockUnlock ?? 'Unlock')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
