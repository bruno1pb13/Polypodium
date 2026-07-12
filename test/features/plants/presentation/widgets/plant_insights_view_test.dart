import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_insights_view.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_photos_sliver.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  _FakeTransparencyNotifier(this.value);
  final bool value;

  @override
  bool build() => value;
}

EntryModel _entry(
  String id,
  DateTime date,
  EntryType type, {
  double? numericValue,
  String? photoPath,
}) =>
    EntryModel(
      id: id,
      plantId: 'plant1',
      date: date,
      type: type,
      numericValue: numericValue,
      photoPath: photoPath,
      createdAt: date,
    );

PlantWithSpecies _pws() {
  final now = DateTime(2026, 7, 1);
  return PlantWithSpecies(
    plant: PlantModel(
      id: 'plant1',
      speciesId: 'sp1',
      nickname: 'Samambaia',
      soilId: 'soil1',
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

Widget _wrap(Widget child, {bool transparent = true}) => ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(() => _FakeTransparencyNotifier(transparent)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  final base = DateTime(2026, 6, 1);

  List<EntryModel> richEntries() => [
        _entry('h1', base, EntryType.height, numericValue: 20),
        _entry('h2', base.add(const Duration(days: 10)), EntryType.height,
            numericValue: 26.5),
        _entry('h3', base.add(const Duration(days: 20)), EntryType.height,
            numericValue: 31),
        _entry('f1', base.add(const Duration(days: 5)), EntryType.fertilizer),
        _entry('p1', base.add(const Duration(days: 15)), EntryType.pruning),
        _entry('o1', base, EntryType.observation, numericValue: 3),
        _entry('o2', base.add(const Duration(days: 12)),
            EntryType.observation, numericValue: 4),
        _entry('o3', base.add(const Duration(days: 22)),
            EntryType.observation, numericValue: 5),
        _entry('pest', base.add(const Duration(days: 8)), EntryType.pest,
            numericValue: 2),
        for (var i = 0; i < 5; i++)
          _entry('w$i', base.add(Duration(days: i * 4)),
              EntryType.irrigation),
      ];

  group('PlantInsightsView', () {
    testWidgets('renders the three charts with rich data', (tester) async {
      await tester.pumpWidget(
        _wrap(PlantInsightsView(entries: richEntries(), pws: _pws())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsNWidgets(2));
      expect(find.byType(BarChart), findsOneWidget);
      // Current-value stats in the card headers (direct labels).
      expect(find.text('31 cm'), findsOneWidget);
      expect(find.textContaining('5/5'), findsOneWidget);
      // Watering caption with average and ideal frequency.
      expect(find.textContaining('4'), findsWidgets);
    });

    testWidgets('renders in non-transparent (Material) mode too',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlantInsightsView(entries: richEntries(), pws: _pws()),
          transparent: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsNWidgets(2));
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('shows global empty message without chartable data',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlantInsightsView(entries: const [], pws: null)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('shows per-chart hint when a series has a single point',
        (tester) async {
      final entries = [
        _entry('h1', base, EntryType.height, numericValue: 20),
        for (var i = 0; i < 3; i++)
          _entry('w$i', base.add(Duration(days: i * 3)),
              EntryType.irrigation),
      ];
      await tester.pumpWidget(
        _wrap(PlantInsightsView(entries: entries, pws: null)),
      );
      await tester.pumpAndSettle();

      // Watering chart renders; height/health show hints instead.
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('handles two measurements on the same instant',
        (tester) async {
      final entries = [
        _entry('h1', base, EntryType.height, numericValue: 20),
        _entry('h2', base, EntryType.height, numericValue: 20),
      ];
      await tester.pumpWidget(
        _wrap(PlantInsightsView(entries: entries, pws: null)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });
  });

  group('PlantPhotosSliver', () {
    Widget wrapSliver(Widget sliver, {bool transparent = true}) => _wrap(
          SizedBox(
            height: 400,
            child: CustomScrollView(slivers: [sliver]),
          ),
          transparent: transparent,
        );

    testWidgets('shows empty message without photos', (tester) async {
      await tester.pumpWidget(
        wrapSliver(PlantPhotosSliver(entries: [
          _entry('h1', base, EntryType.height, numericValue: 20),
        ])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows one tile per photo entry', (tester) async {
      await tester.pumpWidget(
        wrapSliver(PlantPhotosSliver(entries: [
          _entry('e1', base, EntryType.observation,
              photoPath: 'C:/nonexistent/a.jpg'),
          _entry('e2', base.add(const Duration(days: 3)),
              EntryType.irrigation, photoPath: 'C:/nonexistent/b.jpg'),
        ])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNWidgets(2));
    });
  });
}
