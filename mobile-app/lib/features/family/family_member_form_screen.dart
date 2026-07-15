import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';
import 'family_providers.dart';
import '../../core/widgets/glass_app_bar.dart';

class FamilyMemberFormScreen extends ConsumerStatefulWidget {
  const FamilyMemberFormScreen({super.key, this.memberId});

  final String? memberId;

  @override
  ConsumerState<FamilyMemberFormScreen> createState() => _FamilyMemberFormScreenState();
}

class _FamilyMemberFormScreenState extends ConsumerState<FamilyMemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dateOfBirth = DateTime.now().subtract(const Duration(days: 365 * 6));
  Gender _gender = Gender.male;
  int _level = 1;
  bool _isSaving = false;
  bool _loaded = false;
  FamilyMember? _existing;

  bool get _isEdit => widget.memberId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else {
      _loaded = true;
    }
  }

  Future<void> _loadExisting() async {
    final members = await ref.read(familyMembersProvider.future);
    FamilyMember? member;
    for (final m in members) {
      if (m.id == widget.memberId) {
        member = m;
        break;
      }
    }
    final foundMember = member;
    if (foundMember != null && mounted) {
      setState(() {
        _existing = foundMember;
        _nameController.text = foundMember.name;
        _notesController.text = foundMember.medicalNotes;
        _dateOfBirth = foundMember.dateOfBirth;
        _gender = foundMember.gender;
        _level = foundMember.swimmingLevel;
        _loaded = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      if (_isEdit && _existing != null) {
        await ref.read(familyRepositoryProvider).updateFamilyMember(
              _existing!.copyWith(
                name: _nameController.text.trim(),
                dateOfBirth: _dateOfBirth,
                gender: _gender,
                medicalNotes: _notesController.text.trim(),
                swimmingLevel: _level,
              ),
            );
      } else {
        await ref.read(familyRepositoryProvider).addFamilyMember(
              FamilyMember(
                id: '',
                userId: user.id,
                name: _nameController.text.trim(),
                dateOfBirth: _dateOfBirth,
                gender: _gender,
                medicalNotes: _notesController.text.trim(),
                swimmingLevel: _level,
              ),
            );
      }
      ref.invalidate(familyMembersProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: GlassAppBar(title: Text(_isEdit ? l10n.familyEdit : l10n.familyAdd)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: l10n.familyName),
                        validator: (v) => Validators.required(v, l10n),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dateOfBirth,
                            firstDate: DateTime.now().subtract(const Duration(days: 365 * 80)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _dateOfBirth = picked);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: l10n.familyDateOfBirth),
                          child: Text(AppDateFormat.fullDate(_dateOfBirth, locale)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.familyGender, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      SegmentedButton<Gender>(
                        segments: [
                          ButtonSegment(value: Gender.male, label: Text(l10n.familyGenderMale)),
                          ButtonSegment(value: Gender.female, label: Text(l10n.familyGenderFemale)),
                        ],
                        selected: {_gender},
                        onSelectionChanged: (s) => setState(() => _gender = s.first),
                      ),
                      const SizedBox(height: 20),
                      Text('${l10n.familySwimmingLevel}: ${l10n.familyLevelLabel(_level)}'),
                      Slider(
                        value: _level.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$_level',
                        onChanged: (v) => setState(() => _level = v.round()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(labelText: l10n.familyMedicalNotes),
                      ),
                      const SizedBox(height: 24),
                      if (_isEdit && _existing != null) ...[
                        Text(l10n.familyBadges, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        if (_existing!.badges.isEmpty)
                          Text(l10n.familyNoBadgesYet, style: Theme.of(context).textTheme.bodySmall)
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _existing!.badges
                                .map((b) => Chip(
                                      avatar: const Icon(Icons.emoji_events_rounded, size: 16, color: Colors.amber),
                                      label: Text(b.title),
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 20),
                        Text(l10n.familyProgressNotes, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        if (_existing!.progressNotes.isEmpty)
                          Text(l10n.familyNoNotesYet, style: Theme.of(context).textTheme.bodySmall)
                        else
                          ..._existing!.progressNotes.map(
                            (n) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(n.note),
                                subtitle: Text('${n.instructorName} · ${AppDateFormat.dayMonth(n.date, locale)}'),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                      AppButton(label: l10n.actionSave, isLoading: _isSaving, onPressed: _save),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
