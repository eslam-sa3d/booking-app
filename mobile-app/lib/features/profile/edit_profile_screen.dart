import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/avatar_placeholder.dart';
import '../../data/datasources/mock/mock_auth_repository.dart' show AuthException;
import '../auth/auth_controller.dart';
import '../../core/widgets/glass_app_bar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final source = await showAppBottomSheet<ImageSource>(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profileChooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.profileTakePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await ref.read(authRepositoryProvider).uploadProfilePhoto(File(picked.path));
      await ref.read(authControllerProvider.notifier).updateProfile(user.copyWith(photoUrl: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profilePhotoUpdated)));
      }
    } catch (e) {
      if (mounted) {
        final message = e is AuthException ? e.message : l10n.profilePhotoUploadError;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  /// Prompts for the account password and returns it, or null if the user
  /// cancels. Used to satisfy Firebase's `requires-recent-login` guard
  /// before sensitive operations like changing the account email.
  Future<String?> _promptForPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showAppDialog<String>(
      context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileConfirmPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.profileReauthMessage),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.authPassword),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
    return (result == null || result.isEmpty) ? null : result;
  }

  Future<void> _updateEmailWithReauth(String newEmail) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.updateEmail(newEmail);
    } on AuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final password = await _promptForPassword();
        if (password == null) {
          throw AuthException(l10n.profileEmailReauthRequired);
        }
        await repo.reauthenticate(password: password);
        await repo.updateEmail(newEmail);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final newEmail = _emailController.text.trim();
    final emailChanged = newEmail.isNotEmpty && newEmail.toLowerCase() != user.email.toLowerCase();

    try {
      if (emailChanged) {
        await _updateEmailWithReauth(newEmail);
      }
      // The AppUser.email field itself only flips once the user confirms
      // the verification link Firebase just sent — don't write the new
      // address to Firestore yet, just the fields that took effect now.
      await ref.read(authControllerProvider.notifier).updateProfile(
            user.copyWith(name: _nameController.text.trim(), phone: _phoneController.text.trim()),
          );
      if (mounted) {
        if (emailChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.profileEmailVerificationSent(newEmail))),
          );
        }
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final message = e is AuthException ? e.message : l10n.errorGeneric;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.profileEditProfile)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      if (user?.photoUrl != null)
                        CircleAvatar(radius: 44, backgroundImage: NetworkImage(user!.photoUrl!))
                      else
                        AvatarPlaceholder(initials: user?.initials ?? '?', size: 88),
                      if (_isUploadingPhoto)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Semantics(
                          button: true,
                          label: l10n.profileChangePhoto,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isUploadingPhoto ? null : _pickPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.authFullName),
                  validator: (v) => Validators.required(v, l10n),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.authEmail,
                    helperText: l10n.profileEmailChangeHelper,
                    helperMaxLines: 2,
                  ),
                  validator: (v) => Validators.email(v, l10n),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.authPhone),
                  validator: (v) => Validators.required(v, l10n),
                ),
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  label: l10n.actionSave,
                  child: AppButton(label: l10n.actionSave, isLoading: _isSaving, onPressed: _save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
