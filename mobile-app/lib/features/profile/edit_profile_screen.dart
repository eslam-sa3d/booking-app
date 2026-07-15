import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/avatar_placeholder.dart';
import '../../core/widgets/primary_button.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await ref.read(authControllerProvider.notifier).updateProfile(
          user.copyWith(name: _nameController.text.trim(), phone: _phoneController.text.trim()),
        );
    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
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
                      AvatarPlaceholder(initials: user?.initials ?? '?', size: 88),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo upload coming soon')),
                          ),
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
                  initialValue: user?.email,
                  enabled: false,
                  decoration: InputDecoration(labelText: l10n.authEmail),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.authPhone),
                  validator: (v) => Validators.required(v, l10n),
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: l10n.actionSave, isLoading: _isSaving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
