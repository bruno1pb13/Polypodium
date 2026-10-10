import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../domain/pot_model.dart';
import '../providers/pots_providers.dart';
import '../widgets/pot_ui.dart';

/// Creates or edits a pot; pops with the saved [PotModel].
class AddEditPotScreen extends ConsumerStatefulWidget {
  /// The pot being edited; null to create one.
  final PotModel? pot;

  /// Prefilled values of a new pot (e.g. from a repotting form).
  final PotModel? defaults;

  const AddEditPotScreen({super.key, this.pot, this.defaults});

  @override
  ConsumerState<AddEditPotScreen> createState() => _AddEditPotScreenState();
}

class _AddEditPotScreenState extends ConsumerState<AddEditPotScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _diameterCtrl;
  late final TextEditingController _notesCtrl;
  late PotKind _kind;
  PotMaterial? _material;
  String? _locationId;
  bool _saving = false;

  bool get _isEditing => widget.pot != null;

  @override
  void initState() {
    super.initState();
    final source = widget.pot ?? widget.defaults;
    _nameCtrl = TextEditingController(text: source?.name ?? '');
    _diameterCtrl = TextEditingController(
        text: source?.diameterCm == null
            ? ''
            : formatPotDiameter(source!.diameterCm!));
    _notesCtrl = TextEditingController(text: source?.notes ?? '');
    _kind = source?.kind ?? PotKind.pot;
    _material = source?.material;
    _locationId = source?.locationId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _diameterCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final locations = ref.watch(locationsNotifierProvider).value ?? const [];
    // A location that was deleted meanwhile can't stay selected.
    final locationId =
        locations.any((l) => l.id == _locationId) ? _locationId : null;
    final labelStyle = TextStyle(color: context.glass.fgMuted, fontSize: 13);

    return PotScreenScaffold(
      title: _isEditing ? l10n.editPot : l10n.newPotTitle,
      body: Theme(
        data: potFormTheme(context),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            children: [
              PotGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      key: const Key('potName'),
                      controller: _nameCtrl,
                      style: TextStyle(color: context.glass.fg),
                      decoration: InputDecoration(
                        labelText: '${l10n.nameLabel} *',
                        hintText: l10n.potNameHint,
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.potNameRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.potKindLabel, style: labelStyle),
                    const SizedBox(height: 8),
                    PotChoiceChips<PotKind>(
                      values: PotKind.values,
                      selected: _kind,
                      allowClear: false,
                      label: (k) => '${k.emoji} ${k.label(l10n)}',
                      onChanged: (k) => setState(() => _kind = k ?? _kind),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _diameterCtrl,
                      style: TextStyle(color: context.glass.fg),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.potDiameterField,
                        suffixText: 'cm',
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      validator: (v) => v != null &&
                              v.trim().isNotEmpty &&
                              parsePotDiameter(v) == null
                          ? l10n.invalidNumber
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.potMaterialLabel, style: labelStyle),
                    const SizedBox(height: 8),
                    PotChoiceChips<PotMaterial>(
                      values: PotMaterial.values,
                      selected: _material,
                      label: (m) => m.label(l10n),
                      onChanged: (m) => setState(() => _material = m),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: locationId,
                      isExpanded: true,
                      dropdownColor: context.glass.menu,
                      iconEnabledColor: context.glass.fgMuted,
                      style: TextStyle(color: context.glass.fg),
                      decoration: InputDecoration(
                        labelText: l10n.locationLabel,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        helperText:
                            _isEditing ? l10n.potLocationCascadeHint : null,
                        helperMaxLines: 2,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.none),
                        ),
                        for (final l in locations)
                          DropdownMenuItem<String?>(
                            value: l.id,
                            child: Text(l.name),
                          ),
                      ],
                      onChanged: (v) => setState(() => _locationId = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesCtrl,
                      style: TextStyle(color: context.glass.fg),
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.potNotesLabel,
                        prefixIcon: const Icon(Icons.notes),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _saving ? null : () => _submit(locationId),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.glass.fg,
                          ),
                        )
                      : Text(
                          _isEditing ? l10n.saveChanges : l10n.addPot,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(String? locationId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final notes = _notesCtrl.text.trim();
      final pot = PotModel(
        id: widget.pot?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        kind: _kind,
        diameterCm: parsePotDiameter(_diameterCtrl.text),
        material: _material,
        locationId: locationId,
        notes: notes.isEmpty ? null : notes,
        createdAt: widget.pot?.createdAt ?? DateTime.now(),
      );
      await ref.read(potMutationsProvider).save(pot);
      if (mounted) Navigator.pop(context, pot);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
