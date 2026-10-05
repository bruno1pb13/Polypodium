import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/theme/app_theme.dart';
import 'package:polypodium/features/entries/domain/carencia.dart';
import 'package:polypodium/features/entries/presentation/providers/carencia_providers.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/labels/presentation/screens/plant_labels_screen.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/plants/presentation/screens/add_edit_plant_screen.dart';
import 'package:polypodium/features/plants/presentation/screens/home_screen.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_list_item.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_providers.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakePlantsNotifier extends PlantsNotifier {
  _FakePlantsNotifier(this.calls);
  final List<String> calls;

  @override
  Stream<List<PlantModel>> build() => Stream.value(const []);

  @override
  Future<void> setStatus(String plantId, PlantStatus status) async =>
      calls.add('status $plantId ${status.name}');

  @override
  Future<void> delete(String plantId) async => calls.add('delete $plantId');
}

class _FakeEntryMutations implements EntryMutations {
  final irrigated = <Set<String>>[];

  @override
  Future<void> recordIrrigation(Iterable<String> plantIds) async =>
      irrigated.add(plantIds.toSet());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptySpeciesNotifier extends SpeciesNotifier {
  @override
  Stream<List<SpeciesModel>> build() => Stream.value(const []);
}

class _EmptyLocationsNotifier extends LocationsNotifier {
  @override
  Stream<List<LocationModel>> build() => Stream.value(const []);
}

class _EmptySoilsNotifier extends SoilsNotifier {
  @override
  Stream<List<SoilModel>> build() => Stream.value(const []);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final now = DateTime.now();

  PlantWithSpecies plant(
    String id,
    String nickname, {
    required int frequencyDays,
    required int wateredDaysAgo,
    PlantStatus status = PlantStatus.active,
    DateTime? createdAt,
  }) =>
      PlantWithSpecies(
        plant: PlantModel(
          id: id,
          speciesId: 's-$id',
          nickname: nickname,
          soilId: 'loamy',
          acquisitionDate: DateTime(2024, 1, 1),
          lastIrrigatedAt: now.subtract(Duration(days: wateredDaysAgo)),
          status: status,
          createdAt: createdAt ?? DateTime(2024, 1, 1),
        ),
        species: SpeciesModel(
          id: 's-$id',
          popularName: 'Espécie $id',
          scientificName: 'Species $id',
          defaultIrrigationFrequencyDays: frequencyDays,
          recommendedSoilIds: const [],
          createdAt: DateTime(2024, 1, 1),
        ),
      );

  // Overdue by two days, so it leads the default (watering needs) sort.
  final samambaia =
      plant('p1', 'Samambaia', frequencyDays: 3, wateredDaysAgo: 5);
  final anturio = plant('p2', 'Antúrio',
      frequencyDays: 7, wateredDaysAgo: 1, createdAt: DateTime(2025, 1, 1));
  final babosa = plant('p3', 'Babosa',
      frequencyDays: 10, wateredDaysAgo: 30, status: PlantStatus.archived);

  late List<String> plantCalls;
  late _FakeEntryMutations mutations;

  Future<void> pump(WidgetTester tester, List<PlantWithSpecies> plants,
      {ThemeData? theme}) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    plantCalls = [];
    mutations = _FakeEntryMutations();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        activeWorkspaceProvider.overrideWithValue(Workspace.newLocal()),
        plantsWithSpeciesProvider.overrideWith((ref) async => plants),
        plantsNotifierProvider
            .overrideWith(() => _FakePlantsNotifier(plantCalls)),
        entryMutationsProvider.overrideWithValue(mutations),
        plantCoverPhotoProvider.overrideWith((ref, id) => Stream.value(null)),
        plantAlertStatusProvider
            .overrideWith((ref, id) => Stream.value(noPlantAlerts)),
        plantCarenciaProvider.overrideWith((ref, id) => id == anturio.plant.id
            ? CarenciaStatus(
                until: DateTime(2026, 10, 12), productNames: const ['Neem'])
            : null),
        // Watched by the add-plant screen opened from the FAB.
        speciesNotifierProvider.overrideWith(_EmptySpeciesNotifier.new),
        locationsNotifierProvider.overrideWith(_EmptyLocationsNotifier.new),
        soilsNotifierProvider.overrideWith(_EmptySoilsNotifier.new),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    // Past the search debounce.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  Future<void> openSortMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the active plants by watering needs', (tester) async {
    await pump(tester, [anturio, samambaia, babosa]);

    expect(find.text('Polypodium'), findsOneWidget);
    expect(find.text('Samambaia'), findsOneWidget);
    expect(find.text('Antúrio'), findsOneWidget);
    expect(find.text('Babosa'), findsNothing);
    expect(tester.getTopLeft(find.text('Samambaia')).dy,
        lessThan(tester.getTopLeft(find.text('Antúrio')).dy));
  });

  testWidgets('a plant in carência shows its badge', (tester) async {
    await pump(tester, [samambaia, anturio]);

    final badge = find.text('Carência até 12/10');
    expect(badge, findsOneWidget);
    expect(
      find.descendant(
          of: find.widgetWithText(PlantListItem, 'Antúrio'), matching: badge),
      findsOneWidget,
    );
  });

  testWidgets('search filters by nickname and species', (tester) async {
    await pump(tester, [anturio, samambaia]);

    await search(tester, 'samamb');
    expect(find.text('Samambaia'), findsOneWidget);
    expect(find.text('Antúrio'), findsNothing);

    // Accent-insensitive, and matches the species name too.
    await search(tester, 'especie p2');
    expect(find.text('Samambaia'), findsNothing);
    expect(find.text('Antúrio'), findsOneWidget);

    await search(tester, 'cacto');
    expect(find.text('Nenhuma planta encontrada'), findsOneWidget);

    await search(tester, '');
    expect(find.text('Samambaia'), findsOneWidget);
    expect(find.text('Antúrio'), findsOneWidget);
  });

  testWidgets('sort menu reorders the list', (tester) async {
    await pump(tester, [anturio, samambaia]);

    await openSortMenu(tester);
    await tester.tap(find.text('Nome (A-Z)'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Antúrio')).dy,
        lessThan(tester.getTopLeft(find.text('Samambaia')).dy));

    await openSortMenu(tester);
    await tester.tap(find.text('Nome (Z-A)'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Samambaia')).dy,
        lessThan(tester.getTopLeft(find.text('Antúrio')).dy));
  });

  testWidgets('"Mostrar arquivadas" toggles the archived plants',
      (tester) async {
    await pump(tester, [samambaia, babosa]);
    expect(find.text('Babosa'), findsNothing);

    await openSortMenu(tester);
    await tester.tap(find.text('Mostrar arquivadas'));
    await tester.pumpAndSettle();
    expect(find.text('Babosa'), findsOneWidget);
    expect(find.text('Samambaia'), findsOneWidget);

    await openSortMenu(tester);
    expect(
      tester
          .widget<CheckedPopupMenuItem<PlantSortOption>>(
              find.byType(CheckedPopupMenuItem<PlantSortOption>))
          .checked,
      isTrue,
    );
    await tester.tap(find.text('Mostrar arquivadas'));
    await tester.pumpAndSettle();
    expect(find.text('Babosa'), findsNothing);
  });

  testWidgets('long press enters selection mode and waters the selection',
      (tester) async {
    await pump(tester, [anturio, samambaia]);

    await tester.longPress(find.text('Samambaia'));
    await tester.pumpAndSettle();
    expect(find.text('1 selecionada(s)'), findsOneWidget);
    expect(find.byTooltip('Regar selecionadas'), findsOneWidget);
    expect(find.byTooltip('Registrar nas selecionadas'), findsOneWidget);
    expect(find.byTooltip('Excluir selecionadas'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    // In selection mode a tap toggles instead of opening the plant.
    await tester.tap(find.text('Antúrio'));
    await tester.pumpAndSettle();
    expect(find.text('2 selecionada(s)'), findsOneWidget);

    await tester.tap(find.byTooltip('Regar selecionadas'));
    await tester.pumpAndSettle();
    expect(mutations.irrigated, [
      {'p1', 'p2'}
    ]);
    expect(find.text('Rega registrada em 2 plantas'), findsOneWidget);
    expect(find.text('Polypodium'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('the selection opens the label generator in list order',
      (tester) async {
    await pump(tester, [anturio, samambaia]);

    await tester.longPress(find.text('Antúrio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Samambaia'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Gerar etiquetas'));
    await tester.pumpAndSettle();

    final screen =
        tester.widget<PlantLabelsScreen>(find.byType(PlantLabelsScreen));
    expect(screen.plantIds, ['p1', 'p2']);

    Navigator.of(tester.element(find.byType(PlantLabelsScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Polypodium'), findsOneWidget);
  });

  testWidgets('cancelling the selection leaves selection mode', (tester) async {
    await pump(tester, [samambaia]);

    await tester.longPress(find.text('Samambaia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Samambaia'));
    await tester.pumpAndSettle();
    expect(find.text('Polypodium'), findsOneWidget);

    await tester.longPress(find.text('Samambaia'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancelar seleção'));
    await tester.pumpAndSettle();
    expect(find.text('Polypodium'), findsOneWidget);
    expect(mutations.irrigated, isEmpty);
  });

  testWidgets('bulk delete suggests archiving', (tester) async {
    await pump(tester, [anturio, samambaia]);

    await tester.longPress(find.text('Samambaia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Antúrio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Excluir selecionadas'));
    await tester.pumpAndSettle();
    expect(find.text('Deletar 2 plantas?'), findsOneWidget);
    expect(
      find.text('Todos os registros dessas plantas serão removidos.\n\n'
          'Para manter os diários, considere arquivá-las.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Arquivar'));
    await tester.pumpAndSettle();
    expect(plantCalls,
        unorderedEquals(['status p1 archived', 'status p2 archived']));
    expect(find.text('Polypodium'), findsOneWidget);
  });

  testWidgets('bulk delete can delete or be cancelled', (tester) async {
    await pump(tester, [samambaia]);

    await tester.longPress(find.text('Samambaia'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Excluir selecionadas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(plantCalls, isEmpty);
    expect(find.text('1 selecionada(s)'), findsOneWidget);

    await tester.tap(find.byTooltip('Excluir selecionadas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();
    expect(plantCalls, ['delete p1']);
  });

  testWidgets('shows the empty state without plants', (tester) async {
    await pump(tester, []);
    expect(find.text('Nenhuma planta cadastrada'), findsOneWidget);
    expect(find.text('Todas as plantas estão arquivadas'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(AddEditPlantScreen), findsOneWidget);
  });

  testWidgets('shows a distinct state when every plant is archived',
      (tester) async {
    await pump(tester, [babosa]);
    expect(find.text('Todas as plantas estão arquivadas'), findsOneWidget);
    expect(find.text('Nenhuma planta cadastrada'), findsNothing);

    await openSortMenu(tester);
    await tester.tap(find.text('Mostrar arquivadas'));
    await tester.pumpAndSettle();
    expect(find.text('Babosa'), findsOneWidget);
  });

  group('theme colors', () {
    Color? textColor(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style?.color;

    for (final (name, theme, glass) in [
      ('light', AppTheme.light, GlassColors.light),
      ('dark', AppTheme.dark, GlassColors.dark),
    ]) {
      testWidgets('text follows the $name theme', (tester) async {
        await pump(tester, [samambaia], theme: theme);

        expect(textColor(tester, 'Polypodium'), glass.fg);
        expect(textColor(tester, 'Samambaia'), glass.fg);
        expect(textColor(tester, 'Espécie p1'), glass.fgMuted);
      });
    }

    testWidgets('dark keeps the white foregrounds', (tester) async {
      await pump(tester, [samambaia], theme: AppTheme.dark);

      expect(textColor(tester, 'Polypodium'), Colors.white);
      expect(textColor(tester, 'Samambaia'), Colors.white);
      expect(textColor(tester, 'Espécie p1'), Colors.white70);
    });
  });

  group('accessibility', () {
    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, [anturio, samambaia]);

      await expectTapTargetGuidelines(tester);
      expect(find.byTooltip('Adicionar planta'), findsOneWidget);
      expect(find.bySemanticsLabel('Selecionar Samambaia'), findsOneWidget);
      // The status badges are read by their label, not the emoji's name.
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('text is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, [anturio, samambaia], theme: theme);
        await paintBackground(tester);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    testWidgets('selection mode meets the guidelines too', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, [anturio, samambaia]);
      await tester.longPress(find.text('Samambaia'));
      await tester.pumpAndSettle();

      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });

    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        setTextScale(tester, scale);
        await pump(tester, [anturio, samambaia, babosa]);
        expect(tester.takeException(), isNull);
        expect(find.text('Samambaia'), findsOneWidget);
      });
    }
  });
}
