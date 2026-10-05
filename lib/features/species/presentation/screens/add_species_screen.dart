import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/emoji_text.dart';
import '../../../soils/presentation/providers/soils_providers.dart';
import '../../domain/species_model.dart';
import '../providers/species_providers.dart';
import '../widgets/species_autocomplete.dart';

class AddSpeciesScreen extends ConsumerStatefulWidget {
  final SpeciesModel? species;

  const AddSpeciesScreen({super.key, this.species});

  @override
  ConsumerState<AddSpeciesScreen> createState() => _AddSpeciesScreenState();
}

class _AddSpeciesScreenState extends ConsumerState<AddSpeciesScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _scientificCtrl;
  late final TextEditingController _popularCtrl;
  late final TextEditingController _frequencyCtrl;
  late final TextEditingController _careNotesCtrl;

  Set<String> _soilIds = {};
  LightRequirement? _light;
  HumidityLevel? _humidity;
  PetToxicity _petToxicity = PetToxicity.unknown;
  Set<int> _floweringMonths = {};
  bool _saving = false;

  bool get _isEditing => widget.species != null;

  @override
  void initState() {
    super.initState();
    final s = widget.species;
    _scientificCtrl = TextEditingController(text: s?.scientificName ?? '');
    _popularCtrl = TextEditingController(text: s?.popularName ?? '');
    _frequencyCtrl = TextEditingController(
      text: s?.defaultIrrigationFrequencyDays?.toString() ?? '',
    );
    _soilIds = s?.recommendedSoilIds.toSet() ?? {};
    _light = s?.light;
    _humidity = s?.humidity;
    _petToxicity = s?.petToxicity ?? PetToxicity.unknown;
    _floweringMonths = {...?s?.floweringMonths};
    _careNotesCtrl = TextEditingController(text: s?.careNotes ?? '');
  }

  @override
  void dispose() {
    _scientificCtrl.dispose();
    _popularCtrl.dispose();
    _frequencyCtrl.dispose();
    _careNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soilsAsync = ref.watch(soilsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditing ? context.l10n.editSpecies : context.l10n.newSpecies),
      ),
      body: soilsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGeneric('$e'))),
        data: (soils) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SpeciesAutocomplete(
                // On the species screen we only want to search the external
                // dataset, not local species.
                localSpecies: const [],
                controller: _popularCtrl,
                label: '${context.l10n.popularNameLabel} *',
                onSelected: (_, popular, scientific) {
                  setState(() {
                    _popularCtrl.text = popular!;
                    _scientificCtrl.text = scientific!;
                  });
                },
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scientificCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.scientificNameLabel} *',
                  hintText: context.l10n.scientificNameHint,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _frequencyCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.defaultIrrigationFrequencyLabel,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) {
                    return context.l10n.positiveNumberRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.recommendedSoils,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: soils.map((soil) {
                  final selected = _soilIds.contains(soil.id);
                  return FilterChip(
                    label: Text(soil.name),
                    selected: selected,
                    onSelected: (on) => setState(() {
                      on ? _soilIds.add(soil.id) : _soilIds.remove(soil.id);
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ..._careSection(context),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing
                        ? context.l10n.saveChanges
                        : context.l10n.addSpecies),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _careSection(BuildContext context) {
    final l10n = context.l10n;
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final monthFormat = DateFormat.MMM(l10n.localeName);
    final monthNameFormat = DateFormat.MMMM(l10n.localeName);

    return [
      Text(l10n.sectionCare, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 16),
      Text(l10n.lightLabel, style: labelStyle),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final light in LightRequirement.values)
            ChoiceChip(
              label: EmojiText(light.emoji, light.label(l10n)),
              selected: _light == light,
              onSelected: (on) => setState(() => _light = on ? light : null),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Text(l10n.humidityLabel, style: labelStyle),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final humidity in HumidityLevel.values)
            ChoiceChip(
              label: EmojiText(humidity.emoji, humidity.label(l10n)),
              selected: _humidity == humidity,
              onSelected: (on) =>
                  setState(() => _humidity = on ? humidity : null),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Text(l10n.petToxicityLabel, style: labelStyle),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final toxicity in PetToxicity.values)
            ChoiceChip(
              label: EmojiText(toxicity.emoji, toxicity.label(l10n)),
              selected: _petToxicity == toxicity,
              onSelected: (_) => setState(() => _petToxicity = toxicity),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Text(l10n.floweringLabel, style: labelStyle),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (var month = 1; month <= 12; month++)
            FilterChip(
              // Read out the full month name instead of the abbreviation.
              label: Semantics(
                label: monthNameFormat.format(DateTime(2000, month)),
                excludeSemantics: true,
                child: Text(monthFormat.format(DateTime(2000, month))),
              ),
              selected: _floweringMonths.contains(month),
              onSelected: (on) => setState(() {
                on
                    ? _floweringMonths.add(month)
                    : _floweringMonths.remove(month);
              }),
            ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _careNotesCtrl,
        decoration: InputDecoration(labelText: l10n.careNotesLabel),
        minLines: 2,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
      ),
    ];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final species = SpeciesModel(
        id: widget.species?.id ?? const Uuid().v4(),
        scientificName: _scientificCtrl.text.trim(),
        popularName: _popularCtrl.text.trim(),
        defaultIrrigationFrequencyDays:
            _frequencyCtrl.text.trim().isEmpty
                ? null
                : int.parse(_frequencyCtrl.text.trim()),
        recommendedSoilIds: _soilIds.toList(),
        light: _light,
        humidity: _humidity,
        petToxicity: _petToxicity,
        floweringMonths: {..._floweringMonths},
        careNotes: _careNotesCtrl.text.trim().isEmpty
            ? null
            : _careNotesCtrl.text.trim(),
        createdAt: widget.species?.createdAt ?? DateTime.now(),
      );
      await ref.read(speciesNotifierProvider.notifier).save(species);
      if (mounted) Navigator.pop(context, species);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
