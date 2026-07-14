import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/storage/photo_storage.dart';
import '../../../../core/storage/photo_storage_provider.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';

// Holds name + dose controllers for one fertilizer product row.
class _ProductEntry {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController doseCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    doseCtrl.dispose();
  }
}

class AddEntryScreen extends ConsumerStatefulWidget {
  /// One entry is created per plant; with a single id this is the regular
  /// "new entry" flow, with several it acts as a bulk entry for all of them.
  final List<String> plantIds;

  AddEntryScreen({super.key, required String plantId}) : plantIds = [plantId];

  const AddEntryScreen.bulk({super.key, required this.plantIds});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _noteCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _pestTypeCtrl = TextEditingController();

  EntryType _type = EntryType.observation;
  String? _photoPath;

  // Chlorosis
  int _chlorosisSeverity = 1;

  // Pest
  int _pestSeverity = 1;

  // Pruning
  String? _pruningReason;

  // Observation health score
  int _healthScore = 0;

  // Irrigation intensity: 1=Escassa 2=Moderada 3=Intensa (0 = not set)
  int _irrigationIntensity = 0;

  // Fertilizer: dynamic list of product rows
  final List<_ProductEntry> _fertilizerProducts = [_ProductEntry()];

  bool _saving = false;
  bool _submitted = false;
  bool _showFieldErrors = false;
  late final PhotoStorage _photoStorage;

  List<({String key, String label})> _pruningReasons(AppLocalizations l10n) => [
        (key: 'formacao', label: l10n.pruningFormation),
        (key: 'limpeza', label: l10n.pruningCleaning),
        (key: 'rejuvenescimento', label: l10n.pruningRejuvenation),
        (key: 'colheita', label: l10n.pruningHarvest),
      ];

  @override
  void initState() {
    super.initState();
    _photoStorage = ref.read(photoStorageProvider);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _heightCtrl.dispose();
    _pestTypeCtrl.dispose();
    for (final p in _fertilizerProducts) {
      p.dispose();
    }
    if (!_submitted && _photoPath != null) {
      _photoStorage.deletePhoto(_photoPath!);
    }
    super.dispose();
  }

  bool get _hasRequiredFieldError {
    if (_type == EntryType.height) {
      final v = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
      return v == null || v <= 0;
    }
    if (_type == EntryType.pest) {
      return _pestTypeCtrl.text.trim().isEmpty;
    }
    return false;
  }

  double? get _numericValue {
    switch (_type) {
      case EntryType.height:
        return double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
      case EntryType.chlorosis:
        return _chlorosisSeverity.toDouble();
      case EntryType.pest:
        return _pestSeverity.toDouble();
      case EntryType.irrigation:
        return _irrigationIntensity > 0 ? _irrigationIntensity.toDouble() : null;
      case EntryType.observation:
        return _healthScore > 0 ? _healthScore.toDouble() : null;
      default:
        return null;
    }
  }

  String? get _extraData {
    switch (_type) {
      case EntryType.pest:
        final t = _pestTypeCtrl.text.trim();
        return t.isEmpty ? null : jsonEncode({'pestType': t});
      case EntryType.fertilizer:
        final products = _fertilizerProducts
            .map((p) {
              final name = p.nameCtrl.text.trim();
              if (name.isEmpty) return null;
              final dose =
                  double.tryParse(p.doseCtrl.text.replaceAll(',', '.'));
              return {'name': name, if (dose != null) 'dose': dose};
            })
            .whereType<Map<String, dynamic>>()
            .toList();
        return products.isEmpty ? null : jsonEncode({'products': products});
      case EntryType.pruning:
        return _pruningReason == null
            ? null
            : jsonEncode({'reason': _pruningReason});
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasTypeCard =
        _type != EntryType.other && _type != EntryType.history;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.plantIds.length > 1
              ? context.l10n.newBulkEntryTitle(widget.plantIds.length)
              : context.l10n.newEntryTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              children: [
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.entryTypeCardTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: EntryType.values
                            .where((t) =>
                                t != EntryType.history && t != EntryType.other)
                            .map((t) {
                          final selected = t == _type;
                          return ChoiceChip(
                            label: Text('${t.emoji} ${t.label(context.l10n)}'),
                            selected: selected,
                            onSelected: (_) => setState(() {
                              _type = t;
                              _showFieldErrors = false;
                            }),
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.2),
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.white12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                if (hasTypeCard) ...[
                  const SizedBox(height: 16),
                  _GlassCard(child: _buildTypeSpecificContent(context)),
                ],
                const SizedBox(height: 16),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.notesTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteCtrl,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: switch (_type) {
                            EntryType.irrigation =>
                              context.l10n.noteHintIrrigation,
                            EntryType.fertilizer =>
                              context.l10n.noteHintFertilizer,
                            EntryType.pruning => context.l10n.noteHintPruning,
                            EntryType.observation =>
                              context.l10n.noteHintObservation,
                            EntryType.height => context.l10n.noteHintHeight,
                            EntryType.chlorosis =>
                              context.l10n.noteHintChlorosis,
                            EntryType.pest => context.l10n.noteHintPest,
                            _ => context.l10n.noteHintDefault,
                          },
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.photoTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_photoPath != null) ...[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_photoPath!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton.filled(
                                onPressed: () {
                                  final path = _photoPath;
                                  setState(() => _photoPath = null);
                                  if (path != null) {
                                    _photoStorage.deletePhoto(path);
                                  }
                                },
                                icon: const Icon(Icons.close, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: _PhotoButton(
                                icon: Icons.photo_camera_outlined,
                                label: context.l10n.camera,
                                onTap: () => _pickPhoto(ImageSource.camera),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PhotoButton(
                                icon: Icons.photo_library_outlined,
                                label: context.l10n.gallery,
                                onTap: () => _pickPhoto(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.plantIds.length > 1
                                ? context.l10n
                                    .saveEntryForPlants(widget.plantIds.length)
                                : context.l10n.saveEntry,
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
        ],
      ),
    );
  }

  Widget _buildTypeSpecificContent(BuildContext context) {
    return switch (_type) {
      EntryType.irrigation => _buildIrrigationFields(context),
      EntryType.fertilizer => _buildFertilizerFields(context),
      EntryType.pruning => _buildPruningFields(context),
      EntryType.observation => _buildObservationFields(context),
      EntryType.height => _buildHeightFields(context),
      EntryType.chlorosis => _buildChlorosisFields(context),
      EntryType.pest => _buildPestFields(context),
      _ => const SizedBox.shrink(),
    };
  }

  // ---------------------------------------------------------------------------
  // Irrigation — 3 quick presets + custom input
  // ---------------------------------------------------------------------------

  List<({int value, String label, String description})> _irrigationOptions(
          AppLocalizations l10n) =>
      [
        (
          value: 1,
          label: l10n.irrigationScarce,
          description: l10n.irrigationScarceDesc
        ),
        (
          value: 2,
          label: l10n.irrigationModerate,
          description: l10n.irrigationModerateDesc
        ),
        (
          value: 3,
          label: l10n.irrigationIntense,
          description: l10n.irrigationIntenseDesc
        ),
      ];

  Widget _buildIrrigationFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(emoji: '💧', label: context.l10n.entryTypeIrrigation),
        const SizedBox(height: 4),
        _HintText(context.l10n.irrigationIntensityHint),
        const SizedBox(height: 12),
        ..._irrigationOptions(context.l10n).map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SelectionRow(
                selected: _irrigationIntensity == o.value,
                label: o.label,
                description: o.description,
                onTap: () => setState(() => _irrigationIntensity =
                    _irrigationIntensity == o.value ? 0 : o.value),
                context: context,
              ),
            )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Fertilizer — dynamic product list
  // ---------------------------------------------------------------------------

  Widget _buildFertilizerFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(emoji: '🌱', label: context.l10n.entryTypeFertilizer),
        const SizedBox(height: 4),
        _HintText(context.l10n.fertilizerProductsHint),
        const SizedBox(height: 12),
        ...List.generate(_fertilizerProducts.length, (i) {
          final p = _fertilizerProducts[i];
          final canRemove = _fertilizerProducts.length > 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _TextField(
                        controller: p.nameCtrl,
                        label:
                            '${context.l10n.productLabel} ${_fertilizerProducts.length > 1 ? "${i + 1}" : ""}',
                        hint: context.l10n.productHint,
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _NumericField(
                        controller: p.doseCtrl,
                        label: context.l10n.doseLabel,
                        suffix: 'ml',
                        hint: '5',
                        onChanged: (_) => setState(() {}),
                        context: context,
                      ),
                    ),
                    if (canRemove) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: IconButton(
                          onPressed: () => setState(() {
                            _fertilizerProducts[i].dispose();
                            _fertilizerProducts.removeAt(i);
                          }),
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.white54, size: 22),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ],
                ),
                if (i < _fertilizerProducts.length - 1)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 1,
                  ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () =>
              setState(() => _fertilizerProducts.add(_ProductEntry())),
          icon: const Icon(Icons.add, size: 18, color: Colors.white70),
          label: Text(
            context.l10n.addProduct,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white24),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Pruning — reason chips
  // ---------------------------------------------------------------------------

  Widget _buildPruningFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(emoji: '✂️', label: context.l10n.entryTypePruning),
        const SizedBox(height: 4),
        _HintText(context.l10n.pruningReasonHint),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pruningReasons(context.l10n).map((r) {
            final selected = _pruningReason == r.key;
            return ChoiceChip(
              label: Text(r.label),
              selected: selected,
              onSelected: (_) =>
                  setState(() => _pruningReason = selected ? null : r.key),
              backgroundColor: Colors.black.withValues(alpha: 0.2),
              selectedColor: Theme.of(context).colorScheme.primary,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Observation — health score 1–5
  // ---------------------------------------------------------------------------

  Widget _buildObservationFields(BuildContext context) {
    final scoreLabels = [
      '',
      context.l10n.healthCritical,
      context.l10n.healthBad,
      context.l10n.healthRegular,
      context.l10n.healthGood,
      context.l10n.healthExcellent,
    ];
    final scoreColors = [
      Colors.transparent,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.yellow.shade600,
      Colors.lightGreen.shade400,
      Colors.green.shade400,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(emoji: '👁', label: context.l10n.entryTypeObservation),
        const SizedBox(height: 4),
        _HintText(context.l10n.healthScoreHint),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final score = i + 1;
            final selected = _healthScore == score;
            return GestureDetector(
              onTap: () =>
                  setState(() => _healthScore = selected ? 0 : score),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected
                      ? scoreColors[score].withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? scoreColors[score] : Colors.white24,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_healthScore > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              scoreLabels[_healthScore],
              style: TextStyle(
                color: scoreColors[_healthScore],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Height
  // ---------------------------------------------------------------------------

  Widget _buildHeightFields(BuildContext context) {
    final hasError = _showFieldErrors && _hasRequiredFieldError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(emoji: '📏', label: context.l10n.heightSectionTitle),
        const SizedBox(height: 12),
        _NumericField(
          controller: _heightCtrl,
          label: '${context.l10n.heightCmLabel} *',
          suffix: 'cm',
          hint: context.l10n.heightHint,
          hasError: hasError,
          errorText: hasError ? context.l10n.heightInvalid : null,
          onChanged: (_) {
            if (_showFieldErrors) setState(() {});
          },
          context: context,
        ),
        const SizedBox(height: 8),
        _HintText(context.l10n.heightMeasureHint),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Chlorosis — severity selector
  // ---------------------------------------------------------------------------

  Widget _buildChlorosisFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(emoji: '🟡', label: context.l10n.entryTypeChlorosis),
        const SizedBox(height: 4),
        _HintText(context.l10n.severitySelectHint),
        const SizedBox(height: 12),
        ..._chlorosisSeverityOptions(context.l10n).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SelectionRow(
                selected: _chlorosisSeverity == s.value,
                label: s.label,
                description: s.description,
                onTap: () => setState(() => _chlorosisSeverity = s.value),
                context: context,
              ),
            )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Pest — identification field + severity selector
  // ---------------------------------------------------------------------------

  Widget _buildPestFields(BuildContext context) {
    final hasError = _showFieldErrors && _hasRequiredFieldError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(emoji: '🐛', label: context.l10n.entryTypePest),
        const SizedBox(height: 12),
        _TextField(
          controller: _pestTypeCtrl,
          label: '${context.l10n.pestTypeLabel} *',
          hint: context.l10n.pestTypeHint,
          hasError: hasError,
          errorText: hasError ? context.l10n.pestTypeRequired : null,
          onChanged: (_) {
            if (_showFieldErrors) setState(() {});
          },
          context: context,
        ),
        const SizedBox(height: 16),
        _HintText(context.l10n.pestSeverityHint),
        const SizedBox(height: 8),
        ..._pestSeverityOptions(context.l10n).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SelectionRow(
                selected: _pestSeverity == s.value,
                label: s.label,
                description: s.description,
                onTap: () => setState(() => _pestSeverity = s.value),
                context: context,
              ),
            )),
      ],
    );
  }

  // ---------------------------------------------------------------------------

  List<({int value, String label, String description})>
      _chlorosisSeverityOptions(AppLocalizations l10n) => [
            (
              value: 0,
              label: l10n.chlorosisCured,
              description: l10n.chlorosisCuredDesc
            ),
            (
              value: 1,
              label: l10n.severityMild,
              description: l10n.chlorosisMildDesc
            ),
            (
              value: 2,
              label: l10n.severityModerate,
              description: l10n.chlorosisModerateDesc
            ),
            (
              value: 3,
              label: l10n.severitySevere,
              description: l10n.chlorosisSevereDesc
            ),
          ];

  List<({int value, String label, String description})> _pestSeverityOptions(
          AppLocalizations l10n) =>
      [
        (
          value: 0,
          label: l10n.pestEradicated,
          description: l10n.pestEradicatedDesc
        ),
        (value: 1, label: l10n.severityMild, description: l10n.pestMildDesc),
        (
          value: 2,
          label: l10n.severityModerate,
          description: l10n.pestModerateDesc
        ),
        (
          value: 3,
          label: l10n.severitySevere,
          description: l10n.pestSevereDesc
        ),
      ];

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 85);
    if (xFile == null) return;

    final oldPath = _photoPath;
    final savedPath = await _photoStorage.savePhoto(File(xFile.path));
    setState(() => _photoPath = savedPath);
    if (oldPath != null) await _photoStorage.deletePhoto(oldPath);
  }

  Future<void> _submit() async {
    if (_hasRequiredFieldError) {
      setState(() => _showFieldErrors = true);
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final note =
          _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
      final mutations = ref.read(entryMutationsProvider);
      for (var i = 0; i < widget.plantIds.length; i++) {
        final plantId = widget.plantIds[i];
        // Each entry owns its photo file (deleting an entry deletes the
        // photo), so extra plants get their own copy of the picked photo.
        final photoPath = i == 0 || _photoPath == null
            ? _photoPath
            : await _photoStorage.savePhoto(File(_photoPath!));
        final entry = EntryModel(
          id: const Uuid().v4(),
          plantId: plantId,
          date: now,
          photoPath: photoPath,
          note: note,
          type: _type,
          numericValue: _numericValue,
          extraData: _extraData,
          createdAt: now,
        );
        await mutations.create(entry);
      }
      _submitted = true;
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String emoji;
  final String label;

  const _SectionTitle({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$emoji $label',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HintText extends StatelessWidget {
  final String text;
  const _HintText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final String hint;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final BuildContext context;

  const _NumericField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.hint,
    this.hasError = false,
    this.errorText,
    this.onChanged,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hasError ? Colors.redAccent : Colors.white70,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.white54),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: hasError ? Colors.redAccent : Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final BuildContext context;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.hasError = false,
    this.errorText,
    this.onChanged,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      textCapitalization: TextCapitalization.sentences,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hasError ? Colors.redAccent : Colors.white70,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: hasError ? Colors.redAccent : Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final bool selected;
  final String label;
  final String description;
  final VoidCallback onTap;
  final BuildContext context;

  const _SelectionRow({
    required this.selected,
    required this.label,
    required this.description,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
