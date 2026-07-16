import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
import '../../domain/plant_model.dart';
import '../providers/plants_providers.dart';

class AddEditPlantScreen extends ConsumerStatefulWidget {
  final PlantModel? plant;

  const AddEditPlantScreen({super.key, this.plant});

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
  DateTime _acquisitionDate = DateTime.now();

  bool _isFrequencyAutoFilled = false;
  bool _isSoilAutoFilled = false;
  bool _saving = false;

  bool get _isEditing => widget.plant != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plant;
    _nicknameCtrl = TextEditingController(text: p?.nickname ?? '');
    _speciesSearchCtrl = TextEditingController();
    _frequencyCtrl = TextEditingController(
      text: p?.irrigationFrequencyDays?.toString() ?? '',
    );
    _selectedSpeciesId = p?.speciesId;
    _selectedLocationId = p?.locationId;
    _selectedSoilId = p?.soilId;
    _acquisitionDate = p?.acquisitionDate ?? DateTime.now();

    if (_isEditing && _selectedSpeciesId != null) {
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEditing ? context.l10n.editPlant : context.l10n.newPlant,
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
            child: speciesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.errorGeneric('$e'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (species) => locationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (e, _) => Center(
                  child: Text(
                    context.l10n.errorGeneric('$e'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                data: (locations) => soilsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      context.l10n.errorGeneric('$e'),
                      style: const TextStyle(color: Colors.white),
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
                                  style: const TextStyle(color: Colors.white),
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
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.1),
                                          foregroundColor: Colors.white,
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
                                              Colors.white.withValues(alpha: 0.1),
                                          foregroundColor: Colors.white,
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
                                  style: const TextStyle(color: Colors.white),
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
                                        dropdownColor:
                                            const Color(0xFF1E1E1E),
                                        iconEnabledColor: Colors.white70,
                                        style: const TextStyle(
                                            color: Colors.white),
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
                                            Colors.white.withValues(alpha: 0.1),
                                        foregroundColor: Colors.white,
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
  OutlineInputBorder border([Color color = Colors.white24]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: TextStyle(color: primary),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
      helperStyle: const TextStyle(color: Colors.white60),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
      iconColor: Colors.white70,
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
      style: const TextStyle(
        color: Colors.white,
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
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.acquisitionDateLabel,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMd(context.l10n.localeName).format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
