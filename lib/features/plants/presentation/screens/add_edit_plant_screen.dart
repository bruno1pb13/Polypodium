import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../species/domain/species_model.dart';
import '../../../species/presentation/providers/species_providers.dart';
import '../../../species/presentation/screens/add_species_screen.dart';
import '../../../species/presentation/widgets/species_autocomplete.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../locations/presentation/screens/add_edit_location_screen.dart';
import '../../../soils/domain/soil_model.dart';
import '../../../soils/presentation/providers/soils_providers.dart';
import '../../../soils/presentation/widgets/soil_selection_field.dart';
import '../../../soils/presentation/screens/add_edit_soil_screen.dart';
import '../../domain/plant_lineage.dart';
import '../../domain/plant_model.dart';
import '../providers/plants_providers.dart';
import '../../../../core/theme/glass_colors.dart';

class AddEditPlantScreen extends ConsumerStatefulWidget {
  final PlantModel? plant;

  /// Creates a cutting of this plant: a new plant prefilled with its
  /// species, soil and location, linked to it as the parent.
  final PlantModel? cuttingOf;

  const AddEditPlantScreen({super.key, this.plant}) : cuttingOf = null;

  const AddEditPlantScreen.cutting({super.key, required PlantModel parent})
      : plant = null,
        cuttingOf = parent;

  @override
  ConsumerState<AddEditPlantScreen> createState() => _AddEditPlantScreenState();
}

class _AddEditPlantScreenState extends ConsumerState<AddEditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _speciesSearchCtrl;
  late final TextEditingController _frequencyCtrl;

  String? _selectedSpeciesId;
  String? _tempExternalPopularName;
  String? _tempExternalScientificName;

  String? _selectedLocationId;
  String? _selectedSoilId;
  String? _parentPlantId;
  DateTime _acquisitionDate = DateTime.now();

  bool _isFrequencyAutoFilled = false;
  bool _isSoilAutoFilled = false;
  bool _saving = false;
  bool _nicknameSuggested = false;

  bool get _isEditing => widget.plant != null;

  @override
  void initState() {
    super.initState();
    final parent = widget.cuttingOf;
    final p = widget.plant ??
        parent?.copyWith(irrigationFrequencyDays: null, nickname: '');
    _nicknameCtrl = TextEditingController(text: p?.nickname ?? '');
    _speciesSearchCtrl = TextEditingController();
    _frequencyCtrl = TextEditingController(
      text: p?.irrigationFrequencyDays?.toString() ?? '',
    );
    _selectedSpeciesId = p?.speciesId;
    _selectedLocationId = p?.locationId;
    _selectedSoilId = p?.soilId;
    _parentPlantId = widget.plant?.parentPlantId ?? parent?.id;
    _acquisitionDate = widget.plant?.acquisitionDate ?? DateTime.now();

    if (p != null && _selectedSpeciesId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final speciesList = await ref.read(speciesNotifierProvider.future);
        final match = speciesList.cast<SpeciesModel?>().firstWhere(
              (s) => s?.id == _selectedSpeciesId,
              orElse: () => null,
            );
        if (match != null) {
          setState(() {
            _speciesSearchCtrl.text =
                '${match.popularName} (${match.scientificName})';
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Once: it needs the localizations, which initState can't read.
    final parent = widget.cuttingOf;
    if (parent != null && !_nicknameSuggested) {
      _nicknameSuggested = true;
      _nicknameCtrl.text =
          context.l10n.cuttingNicknameSuggestion(parent.nickname);
    }
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _speciesSearchCtrl.dispose();
    _frequencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(speciesNotifierProvider);
    final locationsAsync = ref.watch(locationsNotifierProvider);
    final soilsAsync = ref.watch(soilsNotifierProvider);
    final plants = ref.watch(plantsNotifierProvider).value ?? const [];
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.glass.fg),
        title: Text(
          _isEditing ? context.l10n.editPlant : context.l10n.newPlant,
          style: TextStyle(
            color: context.glass.fg,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: context.glass.shadow(Colors.black45),
                blurRadius: 4,
              ),
            ],
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
                    context.glass.scrim(0.5),
                    Colors.transparent,
                    context.glass.scrim(0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: speciesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: context.glass.fg),
              ),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.errorGeneric('$e'),
                  style: TextStyle(color: context.glass.fg),
                ),
              ),
              data: (species) => locationsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.glass.fg),
                ),
                error: (e, _) => Center(
                  child: Text(
                    context.l10n.errorGeneric('$e'),
                    style: TextStyle(color: context.glass.fg),
                  ),
                ),
                data: (locations) => soilsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(color: context.glass.fg),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      context.l10n.errorGeneric('$e'),
                      style: TextStyle(color: context.glass.fg),
                    ),
                  ),
                  data: (soils) => Theme(
                    data: _darkFormTheme(context),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                        children: [
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(
                                    context.l10n.sectionIdentification),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _nicknameCtrl,
                                  style: TextStyle(color: context.glass.fg),
                                  decoration: InputDecoration(
                                    labelText:
                                        '${context.l10n.nicknameLabel} *',
                                    hintText: context.l10n.nicknameHint,
                                    prefixIcon: const Icon(
                                        Icons.local_florist_outlined),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? context.l10n.nicknameRequired
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SpeciesAutocomplete(
                                        localSpecies: species,
                                        controller: _speciesSearchCtrl,
                                        helperText: context
                                            .l10n.speciesCustomHelper,
                                        onSelected:
                                            _onSpeciesSelected(species),
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? context.l10n.speciesRequired
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: IconButton.filled(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        tooltip: context.l10n.newSpecies,
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              context.glass.tint(0.1),
                                          foregroundColor: context.glass.fg,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: _createCustomSpecies,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(context.l10n.sectionCare),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SoilSelectionField(
                                        selectedSoil: soils.cast<SoilModel?>().firstWhere(
                                              (s) => s?.id == _selectedSoilId,
                                              orElse: () => null,
                                            ),
                                        isRecommended: _isSoilAutoFilled,
                                        onSoilSelected: (soil) {
                                          setState(() {
                                            _selectedSoilId = soil?.id;
                                            _isSoilAutoFilled = false;
                                          });
                                        },
                                        errorText: _selectedSoilId == null ? null : null, // Handled in submit
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: IconButton.filled(
                                        icon: const Icon(Icons.add_circle_outline),
                                        tooltip: context.l10n.newSoilType,
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              context.glass.tint(0.1),
                                          foregroundColor: context.glass.fg,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AddEditSoilScreen(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _frequencyCtrl,
                                  style: TextStyle(color: context.glass.fg),
                                  decoration: InputDecoration(
                                    labelText:
                                        '${context.l10n.irrigationFrequencyLabel}${_isFrequencyAutoFilled ? ' ${context.l10n.recommendedSuffix}' : ''}',
                                    hintText: context.l10n.optional,
                                    helperText:
                                        context.l10n.irrigationFrequencyHelper,
                                    helperMaxLines: 2,
                                    prefixIcon:
                                        const Icon(Icons.opacity_outlined),
                                  ),
                                  onChanged: (_) {
                                    if (_isFrequencyAutoFilled) {
                                      setState(
                                          () => _isFrequencyAutoFilled = false);
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return null;
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n <= 0) {
                                      return context.l10n.positiveNumberRequired;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(context.l10n.sectionDetails),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        // ignore: deprecated_member_use
                                        value: _selectedLocationId,
                                        isExpanded: true,
                                        dropdownColor: context.glass.menu,
                                        iconEnabledColor: context.glass.fgMuted,
                                        style: TextStyle(
                                            color: context.glass.fg),
                                        decoration: InputDecoration(
                                          labelText:
                                              context.l10n.locationLabel,
                                          prefixIcon: const Icon(
                                              Icons.location_on_outlined),
                                        ),
                                        items: locations
                                            .map((l) => DropdownMenuItem(
                                                  value: l.id,
                                                  child: Text(l.name),
                                                ))
                                            .toList(),
                                        onChanged: (v) => setState(
                                            () => _selectedLocationId = v),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filled(
                                      icon: const Icon(
                                          Icons.add_location_alt_outlined),
                                      tooltip: context.l10n.newLocation,
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            context.glass.tint(0.1),
                                        foregroundColor: context.glass.fg,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AddEditLocationScreen(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _DatePickerTile(
                                  date: _acquisitionDate,
                                  onTap: _pickDate,
                                ),
                                ..._parentField(context, plants),
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
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: context.glass.fg,
                                      ),
                                    )
                                  : Text(
                                      _isEditing
                                          ? context.l10n.saveChanges
                                          : context.l10n.addPlant,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Cutting of" picker. Offers every plant but this one and its
  /// descendants, which would make the lineage a cycle.
  List<Widget> _parentField(BuildContext context, List<PlantModel> plants) {
    final l10n = context.l10n;
    final excluded = lineageExclusions(widget.plant?.id, plants);
    final candidates =
        plants.where((p) => !excluded.contains(p.id)).toList();
    final current = _parentPlantId;
    if (candidates.isEmpty && current == null) return const [];

    String nameOf(PlantModel p) => p.isActive
        ? p.nickname
        : '${p.nickname} · ${p.status.label(l10n)}';
    // A removed parent (or one the list can't offer) stays selectable as is,
    // so editing other fields doesn't drop the link.
    final missingCurrent =
        current != null && candidates.every((p) => p.id != current);
    final currentPlant = plants.where((p) => p.id == current).firstOrNull;

    return [
      const SizedBox(height: 16),
      DropdownButtonFormField<String?>(
        // ignore: deprecated_member_use
        value: current,
        isExpanded: true,
        dropdownColor: context.glass.menu,
        iconEnabledColor: context.glass.fgMuted,
        style: TextStyle(color: context.glass.fg),
        decoration: InputDecoration(
          labelText: l10n.parentPlantLabel,
          helperText: l10n.parentPlantHelper,
          helperMaxLines: 2,
          prefixIcon: const Icon(Icons.call_split),
        ),
        items: [
          DropdownMenuItem<String?>(value: null, child: Text(l10n.none)),
          if (missingCurrent)
            DropdownMenuItem<String?>(
              value: current,
              child: Text(currentPlant != null
                  ? nameOf(currentPlant)
                  : l10n.parentPlantRemoved),
            ),
          for (final p in candidates)
            DropdownMenuItem<String?>(value: p.id, child: Text(nameOf(p))),
        ],
        onChanged: (v) => setState(() => _parentPlantId = v),
      ),
    ];
  }

  void Function(String?, String?, String?) _onSpeciesSelected(
    List<SpeciesModel> species,
  ) {
    return (id, popular, scientific) {
      setState(() {
        _selectedSpeciesId = id;
        _tempExternalPopularName = popular;
        _tempExternalScientificName = scientific;

        if (id != null) {
          final selectedSpecies = species.firstWhere((s) => s.id == id);

          if (selectedSpecies.defaultIrrigationFrequencyDays != null) {
            _frequencyCtrl.text =
                selectedSpecies.defaultIrrigationFrequencyDays.toString();
            _isFrequencyAutoFilled = true;
          } else {
            _frequencyCtrl.text = '';
            _isFrequencyAutoFilled = false;
          }

          if (selectedSpecies.recommendedSoilIds.isNotEmpty) {
            _selectedSoilId = selectedSpecies.recommendedSoilIds.first;
            _isSoilAutoFilled = true;
          }
        } else {
          _frequencyCtrl.text = '';
          _isFrequencyAutoFilled = false;
          _isSoilAutoFilled = false;
        }
      });
    };
  }

  Future<void> _createCustomSpecies() async {
    final created = await Navigator.push<SpeciesModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddSpeciesScreen()),
    );
    if (created == null || !mounted) return;

    final speciesList = await ref.read(speciesNotifierProvider.future);
    if (!mounted) return;
    _speciesSearchCtrl.text =
        '${created.popularName} (${created.scientificName})';
    _onSpeciesSelected(speciesList)(
      created.id,
      created.popularName,
      created.scientificName,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _acquisitionDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpeciesId == null && _tempExternalScientificName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectSpeciesFromList)),
      );
      return;
    }

    if (_selectedSoilId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectSoilType)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      String finalSpeciesId;
      if (_selectedSpeciesId != null) {
        finalSpeciesId = _selectedSpeciesId!;
      } else {
        finalSpeciesId = await ref
            .read(speciesNotifierProvider.notifier)
            .getOrCreateFromExternal(
              popularName: _tempExternalPopularName!,
              scientificName: _tempExternalScientificName!,
            );
      }

      final frequencyText = _frequencyCtrl.text.trim();
      final plant = PlantModel(
        id: widget.plant?.id ?? const Uuid().v4(),
        speciesId: finalSpeciesId,
        nickname: _nicknameCtrl.text.trim(),
        soilId: _selectedSoilId!,
        irrigationFrequencyDays:
            frequencyText.isEmpty ? null : int.parse(frequencyText),
        acquisitionDate: _acquisitionDate,
        locationId: _selectedLocationId,
        lastIrrigatedAt: widget.plant?.lastIrrigatedAt,
        lastPesticideAppliedAt: widget.plant?.lastPesticideAppliedAt,
        pesticideReapplicationDays: widget.plant?.pesticideReapplicationDays,
        status: widget.plant?.status ?? PlantStatus.active,
        statusChangedAt: widget.plant?.statusChangedAt,
        parentPlantId: _parentPlantId,
        createdAt: widget.plant?.createdAt ?? DateTime.now(),
      );

      await ref.read(plantsNotifierProvider.notifier).save(plant);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

ThemeData _darkFormTheme(BuildContext context) {
  final base = Theme.of(context);
  final primary = base.colorScheme.primary;
  OutlineInputBorder border([Color? color]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color ?? context.glass.outline),
      );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: context.glass.tint(0.05),
      labelStyle: TextStyle(color: context.glass.fgMuted),
      floatingLabelStyle: TextStyle(color: primary),
      hintStyle: TextStyle(color: context.glass.fgAlpha(0.4)),
      helperStyle: TextStyle(color: context.glass.fgSubtle),
      prefixIconColor: context.glass.fgMuted,
      suffixIconColor: context.glass.fgMuted,
      iconColor: context.glass.fgMuted,
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(primary),
      errorBorder: border(base.colorScheme.error),
      focusedErrorBorder: border(base.colorScheme.error),
      errorStyle: TextStyle(color: base.colorScheme.error),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.4),
      selectionHandleColor: primary,
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.glass.fg,
        fontSize: 18,
        fontWeight: FontWeight.bold,
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
            color: context.glass.scrim(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.glass.tint(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerTile({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: context.glass.tint(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.glass.outline),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: context.glass.fgMuted, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.acquisitionDateLabel,
                      style:
                          TextStyle(color: context.glass.fgMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMd(context.l10n.localeName).format(date),
                      style: TextStyle(
                        color: context.glass.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.glass.fgFaint),
            ],
          ),
        ),
      ),
    );
  }
}
