// Temporary visual preview for the plant insights charts.
// Run with: flutter run -d windows -t lib/dev_insights_preview.dart
// Not part of the app; delete after visual verification.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/enums.dart';
import 'core/theme/app_theme.dart';
import 'features/entries/domain/entry_model.dart';
import 'features/plants/domain/plant_model.dart';
import 'features/plants/presentation/widgets/plant_insights_view.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/species/domain/species_model.dart';
import 'l10n/app_localizations.dart';

class _ForcedTransparency extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

void main() {
  runApp(
    ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_ForcedTransparency.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const _Preview(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

EntryModel _e(String id, DateTime date, EntryType type,
        {double? nv}) =>
    EntryModel(
      id: id,
      plantId: 'p1',
      date: date,
      type: type,
      numericValue: nv,
      createdAt: date,
    );

List<EntryModel> _sample() {
  final b = DateTime(2026, 4, 1);
  return [
    // Heights over ~3 months
    _e('h1', b, EntryType.height, nv: 18),
    _e('h2', b.add(const Duration(days: 14)), EntryType.height, nv: 21),
    _e('h3', b.add(const Duration(days: 30)), EntryType.height, nv: 22.5),
    _e('h4', b.add(const Duration(days: 47)), EntryType.height, nv: 27),
    _e('h5', b.add(const Duration(days: 61)), EntryType.height, nv: 33),
    _e('h6', b.add(const Duration(days: 76)), EntryType.height, nv: 35.5),
    _e('h7', b.add(const Duration(days: 92)), EntryType.height, nv: 41),
    // Care events
    _e('f1', b.add(const Duration(days: 20)), EntryType.fertilizer),
    _e('f2', b.add(const Duration(days: 55)), EntryType.fertilizer),
    _e('p1', b.add(const Duration(days: 40)), EntryType.pruning),
    // Health observations
    _e('o1', b, EntryType.observation, nv: 4),
    _e('o2', b.add(const Duration(days: 15)), EntryType.observation, nv: 3),
    _e('o3', b.add(const Duration(days: 28)), EntryType.observation, nv: 2),
    _e('o4', b.add(const Duration(days: 45)), EntryType.observation, nv: 3),
    _e('o5', b.add(const Duration(days: 62)), EntryType.observation, nv: 4),
    _e('o6', b.add(const Duration(days: 90)), EntryType.observation, nv: 5),
    _e('pest1', b.add(const Duration(days: 22)), EntryType.pest, nv: 2),
    _e('pest2', b.add(const Duration(days: 50)), EntryType.pest, nv: 0),
    // Waterings with slightly irregular intervals
    for (final (i, gap) in const [0, 4, 9, 13, 19, 24, 28, 35, 40, 44, 51, 55]
        .indexed)
      _e('w$i', b.add(Duration(days: gap)), EntryType.irrigation),
  ];
}

PlantWithSpecies _pws() {
  final now = DateTime(2026, 4, 1);
  return PlantWithSpecies(
    plant: PlantModel(
      id: 'p1',
      speciesId: 'sp1',
      nickname: 'Samambaia',
      soilId: 's1',
      acquisitionDate: now,
      createdAt: now,
    ),
    species: SpeciesModel(
      id: 'sp1',
      scientificName: 'Nephrolepis exaltata',
      popularName: 'Samambaia',
      defaultIrrigationFrequencyDays: 5,
      recommendedSoilIds: const [],
      createdAt: now,
    ),
  );
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  child: PlantInsightsView(
                    entries: _sample(),
                    pws: _pws(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
