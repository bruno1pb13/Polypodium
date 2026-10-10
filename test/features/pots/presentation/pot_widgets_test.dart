import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/pots/domain/pot_model.dart';
import 'package:polypodium/features/pots/domain/pot_with_plants.dart';
import 'package:polypodium/features/pots/presentation/providers/pots_providers.dart';
import 'package:polypodium/features/pots/presentation/screens/pot_detail_screen.dart';
import 'package:polypodium/features/pots/presentation/widgets/plant_pot_card.dart';
import 'package:polypodium/features/pots/presentation/widgets/pot_picker_sheet.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakePotMutations extends PotMutations {
  _FakePotMutations(super.ref);

  final moves = <String>[];
  final moveAlls = <(String, String?)>[];
  final deleted = <String>[];

  @override
  Future<List<String>> movePlants(Iterable<String> plantIds, String? potId,
      {bool recordEntry = true, bool applyPotLocation = true}) async {
    moves.add('${plantIds.join(',')}->$potId');
    return plantIds.toList();
  }

  @override
  Future<List<String>> moveAllPlants(String fromPotId, String? toPotId) async {
    moveAlls.add((fromPotId, toPotId));
    return const [];
  }

  @override
  Future<int> delete(String potId) async {
    deleted.add(potId);
    return 0;
  }
}

final _species = SpeciesModel(
  id: 's1',
  popularName: 'Samambaia',
  scientificName: 'Nephrolepis exaltata',
  defaultIrrigationFrequencyDays: 3,
  recommendedSoilIds: const [],
  createdAt: DateTime(2024, 1, 1),
);

PlantWithSpecies _plant(String id, String nickname, {PotModel? pot}) =>
    PlantWithSpecies(
      plant: PlantModel(
        id: id,
        speciesId: 's1',
        nickname: nickname,
        soilId: 'loamy',
        acquisitionDate: DateTime(2024, 1, 1),
        potId: pot?.id,
        createdAt: DateTime(2024, 1, 1),
      ),
      species: _species,
      pot: pot,
    );

final _blue = PotModel(
  id: 'blue',
  name: 'Vaso azul',
  diameterCm: 30,
  material: PotMaterial.clay,
  locationId: 'loc1',
  createdAt: DateTime(2024, 1, 1),
);
final _planter = PotModel(
  id: 'planter',
  name: 'Jardineira',
  kind: PotKind.planter,
  createdAt: DateTime(2024, 2, 1),
);

final _a = _plant('a', 'Samambaia da sala', pot: _blue);
final _b = _plant('b', 'Jiboia', pot: _blue);
final _c = _plant('c', 'Babosa');

final _bluePot = PotWithPlants(
  pot: _blue,
  location: LocationModel(
      id: 'loc1', name: 'Varanda', createdAt: DateTime(2024, 1, 1)),
  plants: [_a, _b],
);
final _planterPot = PotWithPlants(pot: _planter);

void main() {
  late _FakePotMutations mutations;

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        potsWithPlantsProvider
            .overrideWith((ref) async => [_planterPot, _bluePot]),
        potMutationsProvider.overrideWith((ref) {
          return mutations = _FakePotMutations(ref);
        }),
        plantsWithSpeciesProvider.overrideWith((ref) async => [_a, _b, _c]),
        entryMutationsProvider.overrideWith((ref) => EntryMutations(ref)),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ));
    await tester.pumpAndSettle();
  }

  group('PlantPotCard', () {
    testWidgets('shows the pot and the plants sharing it', (tester) async {
      await pump(tester, Scaffold(body: PlantPotCard(plant: _a.plant)));

      expect(find.text('Vaso azul'), findsOneWidget);
      expect(find.text('30 cm · Barro'), findsOneWidget);
      expect(find.text('Divide o vaso com: Jiboia'), findsOneWidget);
      expect(find.text('Mudar de vaso'), findsOneWidget);
    });

    testWidgets('a plant without a pot can be put in one', (tester) async {
      await pump(tester, Scaffold(body: PlantPotCard(plant: _c.plant)));
      expect(find.text('Vaso: Sem vaso'), findsOneWidget);

      await tester.tap(find.text('Mudar de vaso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jardineira'));
      await tester.pumpAndSettle();

      expect(mutations.moves.single, 'c->planter');
    });

    testWidgets('lays out without overflow at text scale 2.0', (tester) async {
      setTextScale(tester, 2.0);
      await pump(tester, Scaffold(body: PlantPotCard(plant: _c.plant)));
      expect(tester.takeException(), isNull);
    });
  });

  group('pot picker', () {
    Future<void> open(WidgetTester tester, {String? currentPotId}) async {
      await pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  showPotPicker(context, currentPotId: currentPotId),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('lists the pots with their plants and "no pot"',
        (tester) async {
      await open(tester, currentPotId: 'blue');

      expect(find.text('Sem vaso'), findsOneWidget);
      expect(find.text('Jardineira'), findsOneWidget);
      expect(find.text('Vaso azul'), findsOneWidget);
      expect(find.textContaining('2 plantas: Samambaia da sala, Jiboia'),
          findsOneWidget);
      expect(find.text('Novo vaso…'), findsOneWidget);
      // Back out without picking.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('search filters by pot or plant name', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField), 'jiboia');
      await tester.pumpAndSettle();

      expect(find.text('Vaso azul'), findsOneWidget);
      expect(find.text('Jardineira'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('picking "no pot" returns an empty choice', (tester) async {
      PotChoice? result;
      await pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  result = await showPotPicker(context, currentPotId: 'blue'),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sem vaso'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.pot, isNull);
    });
  });

  group('PotDetailScreen', () {
    testWidgets('shows the pot data and its plants', (tester) async {
      await pump(tester, const PotDetailScreen(potId: 'blue'));

      expect(find.text('Vaso azul'), findsOneWidget);
      expect(find.text('Varanda'), findsOneWidget);
      expect(find.text('Plantas neste vaso (2)'), findsOneWidget);
      expect(find.text('Samambaia da sala'), findsOneWidget);
      expect(find.text('Jiboia'), findsOneWidget);
    });

    testWidgets('adds the picked plants to the pot', (tester) async {
      await pump(tester, const PotDetailScreen(potId: 'blue'));

      await tester.tap(find.text('Adicionar planta'));
      await tester.pumpAndSettle();
      // Plants already in the pot aren't offered.
      expect(find.text('Babosa'), findsOneWidget);
      expect(find.text('Jiboia'), findsOneWidget); // behind the sheet
      await tester.tap(find.text('Babosa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mover para cá (1)'));
      await tester.pumpAndSettle();

      expect(mutations.moves.single, 'c->blue');
    });

    testWidgets('takes a plant out of the pot', (tester) async {
      await pump(tester, const PotDetailScreen(potId: 'blue'));

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tirar do vaso'));
      await tester.pumpAndSettle();

      expect(mutations.moves.single, 'b->null');
    });

    testWidgets('moves every plant to another pot', (tester) async {
      await pump(tester, const PotDetailScreen(potId: 'blue'));

      await tester.tap(find.text('Mover todas para…'));
      await tester.pumpAndSettle();
      // The pot itself isn't offered.
      expect(find.text('Vaso azul'), findsOneWidget); // the app bar
      await tester.tap(find.text('Jardineira'));
      await tester.pumpAndSettle();

      expect(mutations.moveAlls.single, ('blue', 'planter'));
    });

    testWidgets('deleting asks for confirmation with the plant count',
        (tester) async {
      await pump(tester, const PotDetailScreen(potId: 'blue'));

      await tester.tap(find.byTooltip('Deletar'));
      await tester.pumpAndSettle();
      expect(
          find.text('As 2 plantas deste vaso não serão excluídas; elas '
              'ficarão sem vaso.'),
          findsOneWidget);
      await tester.tap(find.text('Deletar').last);
      await tester.pumpAndSettle();

      expect(mutations.deleted, ['blue']);
    });
  });
}
