import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/agenda/domain/agenda_task.dart';
import 'package:polypodium/features/dashboard/domain/garden_overview.dart';
import 'package:polypodium/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:polypodium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:polypodium/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakeEntryMutations implements EntryMutations {
  final irrigated = <List<String>>[];

  @override
  Future<void> recordIrrigation(Iterable<String> plantIds) async =>
      irrigated.add(plantIds.toList());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int days) =>
      DateTime(today.year, today.month, today.day - days, 10);

  final varanda = LocationModel(
    id: 'varanda',
    name: 'Varanda',
    createdAt: DateTime(2024, 1, 1),
  );

  PlantWithSpecies plant(String id, {int wateredDaysAgo = 0}) =>
      PlantWithSpecies(
        plant: PlantModel(
          id: id,
          speciesId: 's1',
          nickname: id,
          soilId: 'loamy',
          acquisitionDate: DateTime(2024, 1, 1),
          lastIrrigatedAt: daysAgo(wateredDaysAgo),
          locationId: varanda.id,
          createdAt: DateTime(2024, 1, 1),
        ),
        species: SpeciesModel(
          id: 's1',
          popularName: 'Samambaia-de-metro',
          scientificName: 'Nephrolepis exaltata',
          defaultIrrigationFrequencyDays: 3,
          recommendedSoilIds: const [],
          createdAt: DateTime(2024, 1, 1),
        ),
        location: varanda,
      );

  final samambaia = plant('Samambaia', wateredDaysAgo: 5);
  final jiboia = plant('Jiboia', wateredDaysAgo: 4);
  final hera = plant('Hera');

  AgendaTask waterTask(PlantWithSpecies p, int daysRelative) => AgendaTask(
        plant: p,
        kind: AgendaTaskKind.irrigation,
        entryType: EntryType.irrigation,
        dueDate: DateTime(today.year, today.month, today.day - daysRelative),
        daysRelative: daysRelative,
      );

  EntryModel entry(String id, String plantId, EntryType type, DateTime date) =>
      EntryModel(
        id: id,
        plantId: plantId,
        date: date,
        type: type,
        createdAt: date,
      );

  final garden = [samambaia, jiboia, hera];
  final overview = buildGardenOverview(
    plants: garden,
    tasks: [waterTask(samambaia, 2), waterTask(jiboia, 1)],
    recentEntries: [
      entry('e1', 'Hera', EntryType.irrigation, daysAgo(0)),
      entry('e2', 'Hera', EntryType.fertilizer, daysAgo(1)),
    ],
    conditionEntries: const [],
  );
  final empty = buildGardenOverview(
    plants: const [],
    tasks: const [],
    recentEntries: const [],
    conditionEntries: const [],
  );

  late _FakeEntryMutations mutations;

  Future<void> pump(
    WidgetTester tester,
    GardenOverview overview, {
    List<PlantWithSpecies>? plants,
    Size size = const Size(420, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    mutations = _FakeEntryMutations();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        activeWorkspaceProvider.overrideWithValue(Workspace.newLocal()),
        plantsWithSpeciesProvider.overrideWith((ref) async => plants ?? garden),
        gardenOverviewProvider.overrideWith((ref) async => overview),
        entryMutationsProvider.overrideWithValue(mutations),
        plantCoverPhotoProvider.overrideWith((ref, id) => Stream.value(null)),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('summarizes the garden', (tester) async {
    await pump(tester, overview);

    expect(find.text('2 cuidados para hoje'), findsOneWidget);
    expect(find.text('Plantas'), findsOneWidget);
    expect(find.text('Cuidados de hoje'), findsOneWidget);
    expect(find.text('Irrigação • Atrasado há 2 dias'), findsOneWidget);
    expect(find.text('Saúde do jardim'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('Precisam de água'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Atividade recente'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Seu jardim'), findsOneWidget);
    expect(find.text('Por local'), findsOneWidget);
    expect(find.text('Regas (1)'), findsOneWidget);
    expect(find.text('Outros cuidados (1)'), findsOneWidget);
  });

  testWidgets('waters a single plant or all the due ones', (tester) async {
    await pump(tester, overview);

    await tester.tap(find.byTooltip('Reguei').first);
    await tester.pumpAndSettle();
    expect(mutations.irrigated, [
      ['Samambaia'],
    ]);

    await tester.tap(find.text('Regar todas (2)'));
    await tester.pumpAndSettle();
    expect(mutations.irrigated.last, ['Samambaia', 'Jiboia']);
  });

  testWidgets('welcomes a garden without plants', (tester) async {
    await pump(tester, empty, plants: const []);

    expect(find.text('Tudo em dia por aqui 🌿'), findsOneWidget);
    expect(find.text('Boas-vindas ao seu jardim'), findsOneWidget);
    expect(find.text('Cuidados de hoje'), findsNothing);
  });

  testWidgets('pairs the cards side by side when wide', (tester) async {
    await pump(tester, overview, size: const Size(1400, 1000));

    Offset cardOf(String title) => tester.getTopLeft(find
        .ancestor(of: find.text(title), matching: find.byType(DashboardCard))
        .first);
    final today = cardOf('Cuidados de hoje');
    final health = cardOf('Saúde do jardim');
    expect(health.dy, today.dy);
    expect(health.dx, greaterThan(today.dx));
  });

  group('accessibility', () {
    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        setTextScale(tester, scale);
        await pump(tester, overview);
        await tester.scrollUntilVisible(find.text('Atividade recente'), 300,
            scrollable: find.byType(Scrollable).first);
      });
    }
  });
}
