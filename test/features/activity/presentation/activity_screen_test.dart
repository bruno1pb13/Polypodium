import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/activity/domain/garden_activity.dart';
import 'package:polypodium/features/activity/presentation/providers/activity_providers.dart';
import 'package:polypodium/features/activity/presentation/screens/activity_screen.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakeEntriesRepository implements EntriesRepository {
  final since = <DateTime>[];

  final datesSince = <DateTime>[];

  @override
  Stream<List<EntryDate>> watchDatesSince(DateTime since) {
    datesSince.add(since);
    return Stream.value(const []);
  }

  @override
  Stream<List<EntryModel>> watchSince(DateTime since) {
    this.since.add(since);
    return Stream.value(const []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int days, {int hour = 10}) =>
      DateTime(today.year, today.month, today.day - days, hour);

  final hera = PlantWithSpecies(
    plant: PlantModel(
      id: 'hera',
      speciesId: 's1',
      nickname: 'Hera',
      soilId: 'loamy',
      acquisitionDate: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
    ),
    species: SpeciesModel(
      id: 's1',
      popularName: 'Hera',
      scientificName: 'Hedera helix',
      defaultIrrigationFrequencyDays: 3,
      recommendedSoilIds: const [],
      createdAt: DateTime(2024, 1, 1),
    ),
  );

  EntryModel entry(String id, EntryType type, DateTime date, {String? note}) =>
      EntryModel(
        id: id,
        plantId: 'hera',
        date: date,
        type: type,
        note: note,
        createdAt: date,
      );

  GardenActivity activityOf(List<EntryModel> entries) => buildGardenActivity(
        plants: [hera],
        entries: entries,
        entryDates: [
          for (final e in entries) (plantId: e.plantId, date: e.date),
        ],
      );

  final activity = activityOf([
    entry('e1', EntryType.irrigation, daysAgo(0, hour: 8)),
    entry('e2', EntryType.fertilizer, daysAgo(1), note: 'NPK 10-10-10'),
    entry('e3', EntryType.pruning, daysAgo(2)),
  ]);

  Future<void> pump(WidgetTester tester, GardenActivity activity) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        gardenActivityProvider.overrideWith((ref) async => activity),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ActivityScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('charts the activity and lists the entries by day',
      (tester) async {
    await pump(tester, activity);

    expect(find.text('Atividade'), findsOneWidget);
    expect(find.text('3 registros no último ano'), findsOneWidget);
    expect(find.text('Menos'), findsOneWidget);
    expect(find.text('3 dias seguidos'), findsOneWidget);
    expect(find.text('30 dias'), findsOneWidget);
    expect(find.text('Hoje'), findsWidgets);
    expect(find.text('Ontem'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('NPK 10-10-10'), findsOneWidget);
  });

  testWidgets('says when the period has no entries', (tester) async {
    await pump(
        tester,
        buildGardenActivity(
            plants: [hera], entries: const [], entryDates: const []));

    expect(find.text('Nenhum registro nesse período.'), findsOneWidget);
  });

  testWidgets('loads only the entries of the selected period', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _FakeEntriesRepository();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        plantsWithSpeciesProvider.overrideWith((ref) async => [hera]),
        entriesRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ActivityScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(repo.since.last, DateTime(today.year, today.month, today.day - 29));

    await tester.tap(find.text('1 ano'));
    await tester.pumpAndSettle();
    expect(repo.since.last, DateTime(today.year, today.month, today.day - 364));
    // The heatmap always covers a year, whatever the period.
    expect(repo.datesSince.toSet(),
        {DateTime(today.year, today.month, today.day - 364)});
  });

  testWidgets('the year heatmap scrolls, showing today first', (tester) async {
    await pump(tester, activity);

    final scroll = tester.state<ScrollableState>(find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.left));
    expect(scroll.position.pixels, 0);
    expect(scroll.position.maxScrollExtent, greaterThan(0));
  });

  group('accessibility', () {
    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        setTextScale(tester, scale);
        await pump(tester, activity);
        await tester.scrollUntilVisible(find.text('Ontem'), 300,
            scrollable: find.byType(Scrollable).first);
      });
    }
  });
}
