import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/storage/photo_storage.dart';
import '../../../../core/storage/photo_storage_provider.dart';
import '../../../entries/domain/entry_details.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../widgets/entry_forms/chlorosis_form.dart';
import '../widgets/entry_forms/entry_form_widgets.dart';
import '../widgets/entry_forms/entry_note_section.dart';
import '../widgets/entry_forms/entry_photo_section.dart';
import '../widgets/entry_forms/entry_type_selector.dart';
import '../widgets/entry_forms/fertilizer_form.dart';
import '../widgets/entry_forms/height_form.dart';
import '../widgets/entry_forms/irrigation_form.dart';
import '../widgets/entry_forms/observation_form.dart';
import '../widgets/entry_forms/pest_form.dart';
import '../widgets/entry_forms/pesticide_form.dart';
import '../widgets/entry_forms/pruning_form.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  /// One entry is created per plant; with a single id this is the regular
  /// "new entry" flow, with several it acts as a bulk entry for all of them.
  final List<String> plantIds;

  /// Entry type preselected when the screen opens (defaults to observation).
  final EntryType? initialType;

  AddEntryScreen({super.key, required String plantId, this.initialType})
      : plantIds = [plantId];

  const AddEntryScreen.bulk(
      {super.key, required this.plantIds, this.initialType});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _noteCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _pestTypeCtrl = TextEditingController();

  late EntryType _type = widget.initialType ?? EntryType.observation;
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
  final List<FertilizerProductEntry> _fertilizerProducts = [
    FertilizerProductEntry(),
  ];

  // Pesticide: dynamic list of applied-defensivo rows + optional recurrence
  final List<PesticideProductEntry> _pesticideProducts = [
    PesticideProductEntry(),
  ];
  final _pesticideRecurrenceCtrl = TextEditingController();

  bool _saving = false;
  bool _submitted = false;
  bool _showFieldErrors = false;
  late final PhotoStorage _photoStorage;

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
    for (final p in _pesticideProducts) {
      p.dispose();
    }
    _pesticideRecurrenceCtrl.dispose();
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
    if (_type == EntryType.pesticide) {
      return _pesticideProducts.every((p) => p.selected == null);
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

  EntryDetails? get _details {
    switch (_type) {
      case EntryType.pest:
        return PestDetails(pestType: _pestTypeCtrl.text.trim());
      case EntryType.fertilizer:
        return FertilizerDetails(
          products: _fertilizerProducts
              .where((p) => p.nameCtrl.text.trim().isNotEmpty)
              .map((p) => FertilizerProduct(
                    name: p.nameCtrl.text.trim(),
                    dose: double.tryParse(
                        p.doseCtrl.text.replaceAll(',', '.')),
                  ))
              .toList(),
        );
      case EntryType.pruning:
        return PruningDetails(reason: _pruningReason);
      case EntryType.pesticide:
        return PesticideDetails(
          products: _pesticideProducts
              .where((p) => p.selected != null)
              .map((p) {
                final dose = p.doseCtrl.text.trim();
                return PesticideProduct(
                  defensivoId: p.selected!.id,
                  name: p.selected!.name,
                  dose: dose.isEmpty ? null : dose,
                );
              })
              .toList(),
          recurrenceDays: double.tryParse(
                  _pesticideRecurrenceCtrl.text.replaceAll(',', '.'))
              ?.round(),
        );
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
              excludeFromSemantics: true,
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
                EntryGlassCard(
                  child: EntryTypeSelector(
                    selectedType: _type,
                    onSelected: (t) => setState(() {
                      _type = t;
                      _showFieldErrors = false;
                    }),
                  ),
                ),
                if (hasTypeCard) ...[
                  const SizedBox(height: 16),
                  EntryGlassCard(child: _buildTypeSpecificContent()),
                ],
                const SizedBox(height: 16),
                EntryGlassCard(
                  child: EntryNoteSection(controller: _noteCtrl, type: _type),
                ),
                const SizedBox(height: 16),
                EntryGlassCard(
                  child: EntryPhotoSection(
                    photoPath: _photoPath,
                    onRemove: () {
                      final path = _photoPath;
                      setState(() => _photoPath = null);
                      if (path != null) {
                        _photoStorage.deletePhoto(path);
                      }
                    },
                    onPick: _pickPhoto,
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

  Widget _buildTypeSpecificContent() {
    final hasError = _showFieldErrors && _hasRequiredFieldError;
    return switch (_type) {
      EntryType.irrigation => IrrigationForm(
          intensity: _irrigationIntensity,
          onIntensityChanged: (v) => setState(() => _irrigationIntensity = v),
        ),
      EntryType.fertilizer => FertilizerForm(
          products: _fertilizerProducts,
          onAdd: () =>
              setState(() => _fertilizerProducts.add(FertilizerProductEntry())),
          onRemove: (i) => setState(() {
            _fertilizerProducts[i].dispose();
            _fertilizerProducts.removeAt(i);
          }),
          onDoseChanged: (_) => setState(() {}),
        ),
      EntryType.pruning => PruningForm(
          reason: _pruningReason,
          onReasonChanged: (r) => setState(() => _pruningReason = r),
        ),
      EntryType.observation => ObservationForm(
          healthScore: _healthScore,
          onHealthScoreChanged: (s) => setState(() => _healthScore = s),
        ),
      EntryType.height => HeightForm(
          controller: _heightCtrl,
          hasError: hasError,
          onChanged: _refreshFieldErrors,
        ),
      EntryType.chlorosis => ChlorosisForm(
          severity: _chlorosisSeverity,
          onSeverityChanged: (s) => setState(() => _chlorosisSeverity = s),
        ),
      EntryType.pest => PestForm(
          pestTypeController: _pestTypeCtrl,
          severity: _pestSeverity,
          hasError: hasError,
          onPestTypeChanged: _refreshFieldErrors,
          onSeverityChanged: (s) => setState(() => _pestSeverity = s),
        ),
      EntryType.pesticide => PesticideForm(
          products: _pesticideProducts,
          recurrenceController: _pesticideRecurrenceCtrl,
          hasError: hasError,
          onAdd: () =>
              setState(() => _pesticideProducts.add(PesticideProductEntry())),
          onRemove: (i) => setState(() {
            _pesticideProducts[i].dispose();
            _pesticideProducts.removeAt(i);
          }),
          onDefensivoSelected: (p, d) => setState(() => p.selected = d),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  // Re-validates a required field as it is typed, once errors are shown.
  void _refreshFieldErrors(String _) {
    if (_showFieldErrors) setState(() {});
  }

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
      final entries = <EntryModel>[];
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
          extraData: _details?.encode(),
          createdAt: now,
        );
        entries.add(entry);
      }
      await mutations.createMany(entries);
      _submitted = true;
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
