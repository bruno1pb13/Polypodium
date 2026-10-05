import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/theme/app_theme.dart';
import 'package:polypodium/features/entries/domain/carencia.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/carencia_providers.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/plants/presentation/screens/add_edit_plant_screen.dart';
import 'package:polypodium/features/plants/presentation/screens/plant_detail_screen.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_detail/plant_lineage_card.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_detail/plant_status_banners.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_status.dart';
import 'package:polypodium/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakePlantsNotifier extends PlantsNotifier {
  _FakePlantsNotifier(this.plants, this.statusChanges);
  final List<PlantModel> plants;
  final List<(String, PlantStatus)> statusChanges;

  @override
  Stream<List<PlantModel>> build() => Stream.value(plants);

  @override
  Future<void> setStatus(String plantId, PlantStatus status) async =>
      statusChanges.add((plantId, status));
}

final _species = SpeciesModel(
  id: 's1',
  popularName: 'Samambaia',
  scientificName: 'Polypodium vulgare',
  defaultIrrigationFrequencyDays: 3,
  recommendedSoilIds: const [],
  createdAt: DateTime(2024, 1, 1),
);

class _FakeSpeciesNotifier extends SpeciesNotifier {
  _FakeSpeciesNotifier(this.species);
  final SpeciesModel species;

  @override
  Stream<List<SpeciesModel>> build() => Stream.value([species]);
}

class _FakeLocationsNotifier extends LocationsNotifier {
  @override
  Stream<List<LocationModel>> build() => Stream.value([
        LocationModel(
            id: 'l1', name: 'Varanda', createdAt: DateTime(2024, 1, 1)),
      ]);
}

class _FakeSoilsNotifier extends SoilsNotifier {
  @override
  Stream<List<SoilModel>> build() => Stream.value([
        SoilModel(
          id: 'loamy',
          name: 'Franco',
          composition: 'Areia e argila',
          createdAt: DateTime(2024, 1, 1),
        ),
      ]);
}

class _FakeEntriesNotifier extends EntriesNotifier {
  @override
  Stream<List<EntryModel>> build(String plantId) => Stream.value([
        EntryModel(
          id: 'e1',
          plantId: plantId,
          date: DateTime(2026, 3, 1),
          type: EntryType.observation,
          note: 'Folhas novas',
          createdAt: DateTime(2026, 3, 1),
        ),
      ]);
}

class _FakePlantsRepository implements PlantsRepository {
  _FakePlantsRepository(this.plant);
  final PlantModel plant;

  @override
  Future<PlantModel?> getById(String id) async => plant;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PlantModel plant({PlantStatus status = PlantStatus.active}) => PlantModel(
        id: 'p1',
        speciesId: 's1',
        nickname: 'Samambaia da sala',
        soilId: 'loamy',
        locationId: 'l1',
        acquisitionDate: DateTime(2024, 1, 1),
        status: status,
        statusChangedAt:
            status == PlantStatus.active ? null : DateTime(2026, 3, 10),
        createdAt: DateTime(2024, 1, 1),
      );

  late List<(String, PlantStatus)> statusChanges;

  Future<void> pump(WidgetTester tester, PlantModel plant,
      {Size size = const Size(800, 2400),
      ThemeData? theme,
      SpeciesModel? species,
      CarenciaStatus? carencia,
      List<PlantModel> others = const []}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    statusChanges = [];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        plantsNotifierProvider
            .overrideWith(
                () => _FakePlantsNotifier([plant, ...others], statusChanges)),
        plantsRepositoryProvider
            .overrideWithValue(_FakePlantsRepository(plant)),
        speciesNotifierProvider
            .overrideWith(() => _FakeSpeciesNotifier(species ?? _species)),
        locationsNotifierProvider.overrideWith(_FakeLocationsNotifier.new),
        soilsNotifierProvider.overrideWith(_FakeSoilsNotifier.new),
        entriesNotifierProvider('p1').overrideWith(_FakeEntriesNotifier.new),
        latestPlantPhotoProvider('p1')
            .overrideWith((ref) => Stream.value(null)),
        plantAlertStatusProvider('p1').overrideWith((ref) => Stream.value((
              hasActiveChlorosis: false,
              chlorosisSeverity: null,
              hasActivePest: true,
              pestSeverity: 2,
            ))),
        plantRemindersProvider('p1')
            .overrideWith((ref) => Stream.value(const [])),
        plantCarenciaProvider('p1').overrideWith((ref) => carencia),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PlantDetailScreen(plantId: 'p1'),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Finder appBarIcon(IconData icon) =>
      find.descendant(of: find.byType(AppBar), matching: find.byIcon(icon));

  testWidgets('renders the key sections of an active plant', (tester) async {
    await pump(tester, plant());

    // Header
    expect(find.text('Samambaia da sala'), findsNWidgets(2));
    expect(find.text('Samambaia'), findsOneWidget);
    expect(find.text('Polypodium vulgare'), findsOneWidget);
    // Care alerts: never watered.
    expect(find.text('Precisa de água!'), findsOneWidget);
    // Info card
    expect(find.text('Franco'), findsOneWidget);
    expect(find.text('Areia e argila'), findsOneWidget);
    expect(find.text('Varanda'), findsOneWidget);
    expect(find.text('Frequência de irrigação'), findsOneWidget);
    expect(find.text('Praga'), findsOneWidget);
    expect(find.text('Moderada'), findsOneWidget);
    // Reminders card is offered to active plants only.
    expect(find.text('Lembretes'), findsOneWidget);
    expect(find.text('Sem lembretes enquanto inativa. O diário é mantido.'),
        findsNothing);
    // View selector + diary
    expect(find.text('Diário'), findsOneWidget);
    expect(find.text('Gráficos'), findsOneWidget);
    expect(find.text('Fotos'), findsOneWidget);
    expect(find.text('Registros'), findsOneWidget);
    expect(find.textContaining('Folhas novas'), findsOneWidget);
    // FABs
    expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
    expect(find.text('Reguei agora'), findsOneWidget);

    await tester.tap(find.text('Gráficos'));
    await tester.pumpAndSettle();
    expect(find.text('Registros'), findsNothing);
    expect(find.textContaining('Ainda não há dados para gráficos'),
        findsOneWidget);

    await tester.tap(find.text('Fotos'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nenhuma foto nos registros ainda'),
        findsOneWidget);
  });

  testWidgets('renders the lifecycle banner of a non-active plant',
      (tester) async {
    await pump(tester, plant(status: PlantStatus.archived));

    expect(find.text('Arquivada desde 10/03/2026'), findsOneWidget);
    expect(find.text('Sem lembretes enquanto inativa. O diário é mantido.'),
        findsOneWidget);
    expect(find.text('Precisa de água!'), findsNothing);
    expect(find.text('Lembretes'), findsNothing);
    expect(find.text('Reguei agora'), findsNothing);
    expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
    expect(find.text('Registros'), findsOneWidget);
  });

  testWidgets('status menu offers every other status', (tester) async {
    await pump(tester, plant(status: PlantStatus.archived));

    await tester.tap(find.byTooltip('Alterar status'));
    await tester.pumpAndSettle();
    expect(find.text('Reativar'), findsOneWidget);
    expect(find.text('Marcar como morta'), findsOneWidget);
    expect(find.text('Marcar como doada'), findsOneWidget);
    expect(find.text('Arquivar'), findsNothing);

    await tester.tap(find.text('Reativar'));
    await tester.pumpAndSettle();
    expect(statusChanges, [('p1', PlantStatus.active)]);
  });

  testWidgets('delete dialog suggests archiving an active plant',
      (tester) async {
    await pump(tester, plant());

    await tester.tap(appBarIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Deletar planta?'), findsOneWidget);
    expect(
      find.text('Todos os registros desta planta serão removidos.\n\n'
          'Para manter o diário, considere arquivá-la.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Arquivar'));
    await tester.pumpAndSettle();
    expect(find.text('Deletar planta?'), findsNothing);
    expect(statusChanges, [('p1', PlantStatus.archived)]);
  });

  testWidgets('delete dialog of a non-active plant has no archive option',
      (tester) async {
    await pump(tester, plant(status: PlantStatus.dead));

    await tester.tap(appBarIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Todos os registros desta planta serão removidos.'),
        findsOneWidget);
    expect(find.text('Arquivar'), findsNothing);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Deletar planta?'), findsNothing);
    expect(statusChanges, isEmpty);
  });

  group('lineage', () {
    PlantModel relative(String id, String nickname,
            {String? parent, PlantStatus status = PlantStatus.active}) =>
        PlantModel(
          id: id,
          speciesId: 's1',
          nickname: nickname,
          soilId: 'loamy',
          acquisitionDate: DateTime(2024, 1, 1),
          parentPlantId: parent,
          status: status,
          createdAt: DateTime(2024, 1, 1),
        );

    testWidgets('shows the parent and the cuttings', (tester) async {
      await pump(tester, plant().copyWith(parentPlantId: 'mae'), others: [
        relative('mae', 'Samambaia mãe', status: PlantStatus.archived),
        relative('m1', 'Muda 1', parent: 'p1'),
        relative('m2', 'Muda 2', parent: 'p1'),
        relative('x', 'Outra'),
      ]);

      expect(find.text('Muda de'), findsOneWidget);
      expect(find.text('Samambaia mãe · Arquivada'), findsOneWidget);
      expect(find.text('Mudas'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Muda 1'), findsOneWidget);
      expect(find.text('Muda 2'), findsOneWidget);
      expect(find.text('Outra'), findsNothing);
      expect(find.text('Criar muda'), findsOneWidget);
    });

    testWidgets('a deleted parent is shown as removed, without a link',
        (tester) async {
      await pump(tester, plant().copyWith(parentPlantId: 'gone'));

      expect(find.text('Planta removida'), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(PlantLineageCard),
              matching: find.byIcon(Icons.chevron_right)),
          findsNothing);
      expect(find.text('Mudas'), findsNothing);
    });

    testWidgets('"Criar muda" opens the form prefilled from this plant',
        (tester) async {
      await pump(tester, plant());
      await tester.tap(find.text('Criar muda'));
      await tester.pumpAndSettle();

      final screen =
          tester.widget<AddEditPlantScreen>(find.byType(AddEditPlantScreen));
      expect(screen.plant, isNull);
      expect(screen.cuttingOf?.id, 'p1');
    });

    testWidgets('rows open the linked plants', (tester) async {
      final opened = <String>[];
      var created = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          transparencyEnabledNotifierProvider
              .overrideWith(_FakeTransparencyNotifier.new),
        ],
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PlantLineageCard(
              plant: plant().copyWith(parentPlantId: 'mae'),
              plants: [
                relative('mae', 'Samambaia mãe'),
                relative('m1', 'Muda 1', parent: 'p1'),
              ],
              onOpenPlant: opened.add,
              onCreateCutting: () => created++,
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Samambaia mãe'));
      await tester.tap(find.text('Muda 1'));
      await tester.tap(find.text('Criar muda'));
      expect(opened, ['mae', 'm1']);
      expect(created, 1);
    });

    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, plant().copyWith(parentPlantId: 'mae'), others: [
        relative('mae', 'Samambaia mãe'),
        relative('m1', 'Muda 1', parent: 'p1'),
      ]);
      await expectTapTargetGuidelines(tester);
      expect(find.bySemanticsLabel(RegExp('Samambaia mãe')), findsWidgets);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, plant().copyWith(parentPlantId: 'mae'),
            theme: theme,
            others: [
              relative('mae', 'Samambaia mãe'),
              relative('m1', 'Muda 1', parent: 'p1'),
            ]);
        await paintBackground(tester);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    testWidgets('lays out without overflow at text scale 2.0',
        (tester) async {
      setTextScale(tester, 2.0);
      await pump(tester, plant().copyWith(parentPlantId: 'mae'),
          size: const Size(400, 3200),
          others: [
            relative('mae', 'Samambaia mãe com nome comprido'),
            relative('m1', 'Muda 1', parent: 'p1'),
          ]);
      expect(tester.takeException(), isNull);
    });
  });

  group('carência', () {
    final carencia = CarenciaStatus(
      until: DateTime(2026, 10, 12),
      productNames: const ['Óleo de Neem', 'Calda Bordalesa'],
    );

    testWidgets('shows the banner with the date and the products',
        (tester) async {
      await pump(tester, plant(), carencia: carencia);

      expect(find.text('Em carência até 12/10'), findsOneWidget);
      expect(find.text('Não colher — Óleo de Neem, Calda Bordalesa'),
          findsOneWidget);
    });

    testWidgets('has no banner without carência or on an inactive plant',
        (tester) async {
      await pump(tester, plant());
      expect(find.textContaining('Em carência'), findsNothing);

      await pump(tester, plant(status: PlantStatus.archived),
          carencia: carencia);
      expect(find.textContaining('Em carência'), findsNothing);
    });

    testWidgets('does not read emoji names out', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, plant(), carencia: carencia);
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      semantics.dispose();
    });

    // Only the alerts over the background: where the rest of the screen lands
    // on the leaf illustration depends on the banners above it.
    for (final (name, theme) in appThemes) {
      testWidgets('is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(ProviderScope(
          overrides: [
            transparencyEnabledNotifierProvider
                .overrideWith(_FakeTransparencyNotifier.new),
          ],
          child: MaterialApp(
            theme: theme,
            locale: const Locale('pt'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset('assets/images/background.png',
                        fit: BoxFit.cover),
                  ),
                  SafeArea(
                    child: PlantCareAlerts(
                      pws: PlantWithSpecies(plant: plant(), species: _species),
                      carencia: carencia,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
        await paintBackground(tester);
        expect(find.text('Em carência até 12/10'), findsOneWidget);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    // The banner pushes the info card further down the leaf illustration.
    for (final (name, theme) in appThemes) {
      testWidgets('the whole screen is readable in the $name theme',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, plant(), theme: theme, carencia: carencia);
        await paintBackground(tester);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    testWidgets('lays out without overflow at text scale 2.0',
        (tester) async {
      setTextScale(tester, 2.0);
      await pump(tester, plant(),
          size: const Size(400, 3200), carencia: carencia);
      expect(tester.takeException(), isNull);
    });
  });

  group('species care card', () {
    final careSpecies = _species.copyWith(
      light: LightRequirement.indirectBright,
      humidity: HumidityLevel.high,
      petToxicity: PetToxicity.toxic,
      floweringMonths: {10, 3, 9},
      careNotes: 'Borrifar as folhas',
    );

    testWidgets('is hidden when the species has no care sheet',
        (tester) async {
      await pump(tester, plant());
      expect(find.text('Cuidados da espécie'), findsNothing);
    });

    testWidgets('shows the care sheet with the toxicity warning',
        (tester) async {
      await pump(tester, plant(), species: careSpecies);

      expect(find.text('Cuidados da espécie'), findsOneWidget);
      expect(find.text('Luz'), findsOneWidget);
      expect(find.text('Luz indireta'), findsOneWidget);
      expect(find.text('Umidade'), findsOneWidget);
      expect(find.text('Alta'), findsOneWidget);
      expect(find.text('Toxicidade para pets'), findsOneWidget);
      expect(tester.widget<Text>(find.text('Tóxica')).style?.color,
          StatusTone.danger.onLight);
      expect(find.text('Floresce em: mar., set., out.'), findsOneWidget);
      expect(find.text('Borrifar as folhas'), findsOneWidget);
    });

    testWidgets('only shows the filled-in fields', (tester) async {
      await pump(tester, plant(),
          species: _species.copyWith(
              petToxicity: PetToxicity.nonToxic, floweringMonths: {1}));

      expect(find.text('Cuidados da espécie'), findsOneWidget);
      expect(tester.widget<Text>(find.text('Não tóxica')).style?.color,
          StatusTone.positive.onLight);
      expect(find.text('Floresce em: jan.'), findsOneWidget);
      expect(find.text('Luz'), findsNothing);
      expect(find.text('Umidade'), findsNothing);
    });

    testWidgets('does not read emoji names out', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, plant(), species: careSpecies);
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, plant(), theme: theme, species: careSpecies);
        await paintBackground(tester);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    testWidgets('lays out without overflow at text scale 2.0',
        (tester) async {
      setTextScale(tester, 2.0);
      await pump(tester, plant(),
          size: const Size(400, 3200), species: careSpecies);
      expect(tester.takeException(), isNull);
    });
  });

  group('theme colors', () {
    Color? textColor(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style?.color;

    for (final (name, theme, glass) in [
      ('light', AppTheme.light, GlassColors.light),
      ('dark', AppTheme.dark, GlassColors.dark),
    ]) {
      testWidgets('text follows the $name theme', (tester) async {
        await pump(tester, plant(), theme: theme);

        expect(textColor(tester, 'Registros'), glass.fg);
        expect(textColor(tester, 'Samambaia'), glass.fgMuted);
        expect(textColor(tester, 'Polypodium vulgare'), glass.fgFaint);
      });
    }
  });

  group('accessibility', () {
    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, plant());

      await expectTapTargetGuidelines(tester);
      expect(find.byTooltip('Editar planta'), findsOneWidget);
      expect(find.byTooltip('Deletar planta'), findsOneWidget);
      expect(find.byTooltip('Novo Registro'), findsOneWidget);
      // Alerts, status rows and the diary don't read emoji names out.
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);

      await tester.tap(find.text('Gráficos'));
      await tester.pumpAndSettle();
      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('text is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, plant(), theme: theme);
        await paintBackground(tester);
        await expectReadableText(tester);

        await tester.tap(find.text('Gráficos'));
        await tester.pumpAndSettle();
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    testWidgets('the view selector reports the selected view',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, plant());

      expect(
        tester.getSemantics(find.text('Diário')),
        matchesSemantics(
          label: 'Diário',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        setTextScale(tester, scale);
        await pump(tester, plant(), size: const Size(400, 2400));
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Gráficos'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
