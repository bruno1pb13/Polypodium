import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/l10n/l10n.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/plants/presentation/screens/add_edit_plant_screen.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_providers.dart';
import 'package:polypodium/features/soils/presentation/widgets/soil_selection_field.dart';
import 'package:polypodium/features/species/data/external_species_repository.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';
import 'package:polypodium/features/species/presentation/widgets/species_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSpeciesNotifier extends SpeciesNotifier {
  @override
  Stream<List<SpeciesModel>> build() => Stream.value([
        SpeciesModel(
          id: 's1',
          popularName: 'Samambaia',
          scientificName: 'Polypodium vulgare',
          defaultIrrigationFrequencyDays: 3,
          recommendedSoilIds: const ['loamy'],
          createdAt: DateTime(2024, 1, 1),
        ),
        SpeciesModel(
          id: 's2',
          popularName: 'Jiboia',
          scientificName: 'Epipremnum aureum',
          defaultIrrigationFrequencyDays: null,
          recommendedSoilIds: const [],
          createdAt: DateTime(2024, 1, 1),
        ),
      ]);
}

class _FakeLocationsNotifier extends LocationsNotifier {
  @override
  Stream<List<LocationModel>> build() => Stream.value([
        LocationModel(
            id: 'l1', name: 'Varanda', createdAt: DateTime(2024, 1, 1)),
        LocationModel(id: 'l2', name: 'Sala', createdAt: DateTime(2024, 1, 1)),
      ]);
}

class _FakeSoilsNotifier extends SoilsNotifier {
  @override
  Stream<List<SoilModel>> build() => Stream.value([
        SoilModel(id: 'loamy', name: 'Franco', createdAt: DateTime(2024, 1, 1)),
        SoilModel(
            id: 'sandy', name: 'Arenoso', createdAt: DateTime(2024, 1, 1)),
      ]);
}

class _FakeExternalSpeciesRepository extends ExternalSpeciesRepository {
  @override
  Future<void> build() async {}

  @override
  Future<List<ExternalSpecies>> search(String query) async => [];
}

class _FakePlantsRepository implements PlantsRepository {
  _FakePlantsRepository(this.plants);
  final List<PlantModel> plants;
  final saved = <PlantModel>[];

  @override
  Stream<List<PlantModel>> watchAll() => Stream.value(plants);

  @override
  Future<void> save(PlantModel plant) async => saved.add(plant);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEntryMutations implements EntryMutations {
  final created = <EntryModel>[];

  @override
  Future<void> create(EntryModel entry) async => created.add(entry);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late _FakePlantsRepository repository;
  late _FakeEntryMutations mutations;

  // Pushes the screen over a launcher route so the Navigator.pop on save has
  // somewhere to go back to. The launcher watches the plants, as the Home
  // does in the app, so the notifier stays alive while saving.
  Future<void> pump(WidgetTester tester, {PlantModel? plant}) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    repository = _FakePlantsRepository([if (plant != null) plant]);
    mutations = _FakeEntryMutations();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        plantsRepositoryProvider.overrideWithValue(repository),
        entryMutationsProvider.overrideWithValue(mutations),
        speciesNotifierProvider.overrideWith(_FakeSpeciesNotifier.new),
        locationsNotifierProvider.overrideWith(_FakeLocationsNotifier.new),
        soilsNotifierProvider.overrideWith(_FakeSoilsNotifier.new),
        externalSpeciesRepositoryProvider
            .overrideWith(_FakeExternalSpeciesRepository.new),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(
          builder: (context, ref, _) {
            ref.watch(plantsNotifierProvider);
            return Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditPlantScreen(plant: plant)),
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder speciesField() => find.descendant(
      of: find.byType(SpeciesAutocomplete),
      matching: find.byType(TextFormField));

  Future<void> pickSpecies(
      WidgetTester tester, String query, String name) async {
    await tester.enterText(speciesField(), query);
    // Past the autocomplete's debounce.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('creates a plant from the filled form', (tester) async {
    await pump(tester);
    expect(find.text('Nova planta'), findsOneWidget);

    await tester.enterText(field('Apelido *'), '  Samambaia da sala  ');
    await pickSpecies(tester, 'samam', 'Samambaia');

    // Picking the species fills its recommended frequency and soil.
    expect(find.text('Samambaia (Polypodium vulgare)'), findsOneWidget);
    expect(find.text('Frequência de irrigação (dias) (recomendado)'),
        findsOneWidget);
    expect(find.text('Tipo de solo * (recomendado)'), findsOneWidget);
    expect(find.text('Franco'), findsOneWidget);

    // Both can still be overridden.
    await tester.enterText(
        field('Frequência de irrigação (dias) (recomendado)'), '5');
    await tester.pump();
    expect(find.text('Frequência de irrigação (dias)'), findsOneWidget);

    await tester.tap(find.byType(SoilSelectionField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arenoso'));
    await tester.pumpAndSettle();
    expect(find.text('Tipo de solo *'), findsOneWidget);
    expect(find.text('Arenoso'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Varanda').last);
    await tester.pumpAndSettle();

    final now = DateTime.now();
    await tester.tap(find.text('Data de aquisição'));
    await tester.pumpAndSettle();
    await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('1')));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await save(tester, 'Adicionar planta');

    final plant = repository.saved.single;
    expect(plant.id, isNotEmpty);
    expect(plant.nickname, 'Samambaia da sala');
    expect(plant.speciesId, 's1');
    expect(plant.soilId, 'sandy');
    expect(plant.irrigationFrequencyDays, 5);
    expect(plant.locationId, 'l1');
    expect(plant.acquisitionDate, DateTime(now.year, now.month, 1));
    expect(plant.status, PlantStatus.active);
    expect(plant.statusChangedAt, isNull);
    expect(plant.lastIrrigatedAt, isNull);
    expect(find.byType(AddEditPlantScreen), findsNothing);

    // The creation lands in the diary as a history entry.
    final entry = mutations.created.single;
    expect(entry.plantId, plant.id);
    expect(entry.type, EntryType.history);
    expect(entry.note, startsWith(systemL10n().historyPlantAdded));
  });

  testWidgets('a species without defaults clears the frequency',
      (tester) async {
    await pump(tester);
    await pickSpecies(tester, 'samam', 'Samambaia');
    expect(find.text('5'), findsNothing);
    expect(
        tester
            .widget<TextFormField>(
                field('Frequência de irrigação (dias) (recomendado)'))
            .controller!
            .text,
        '3');

    await pickSpecies(tester, 'jib', 'Jiboia');
    final frequency = tester
        .widget<TextFormField>(field('Frequência de irrigação (dias)'))
        .controller!;
    expect(frequency.text, isEmpty);
    // The soil picked for the previous species is kept.
    expect(find.text('Franco'), findsOneWidget);
  });

  testWidgets('editing keeps the fields that are not on the form',
      (tester) async {
    final original = PlantModel(
      id: 'p1',
      speciesId: 's1',
      nickname: 'Samambaia',
      soilId: 'loamy',
      irrigationFrequencyDays: 4,
      acquisitionDate: DateTime(2024, 1, 10),
      locationId: 'l1',
      lastIrrigatedAt: DateTime(2026, 3, 1, 8),
      lastPesticideAppliedAt: DateTime(2026, 2, 20),
      pesticideReapplicationDays: 15,
      status: PlantStatus.archived,
      statusChangedAt: DateTime(2026, 3, 10),
      createdAt: DateTime(2024, 1, 10),
    );
    await pump(tester, plant: original);

    expect(find.text('Editar planta'), findsOneWidget);
    expect(find.text('Samambaia (Polypodium vulgare)'), findsOneWidget);
    expect(find.text('Franco'), findsOneWidget);
    expect(find.text('Varanda'), findsOneWidget);
    expect(find.text('10/01/2024'), findsOneWidget);

    await tester.enterText(field('Apelido *'), 'Samambaia do quarto');
    await save(tester, 'Salvar alterações');

    final plant = repository.saved.single;
    expect(plant.id, 'p1');
    expect(plant.nickname, 'Samambaia do quarto');
    expect(plant.speciesId, 's1');
    expect(plant.soilId, 'loamy');
    expect(plant.irrigationFrequencyDays, 4);
    expect(plant.locationId, 'l1');
    expect(plant.acquisitionDate, DateTime(2024, 1, 10));
    expect(plant.lastIrrigatedAt, DateTime(2026, 3, 1, 8));
    expect(plant.lastPesticideAppliedAt, DateTime(2026, 2, 20));
    expect(plant.pesticideReapplicationDays, 15);
    expect(plant.status, PlantStatus.archived);
    expect(plant.statusChangedAt, DateTime(2026, 3, 10));
    expect(plant.createdAt, DateTime(2024, 1, 10));

    final l10n = systemL10n();
    final entry = mutations.created.single;
    expect(entry.plantId, 'p1');
    expect(entry.type, EntryType.history);
    expect(
      entry.note,
      '${l10n.historyUpdatedHeader}\n'
      '• ${l10n.historyFieldNickname}: Samambaia → Samambaia do quarto',
    );
  });

  testWidgets('saving an unchanged plant writes no history entry',
      (tester) async {
    final original = PlantModel(
      id: 'p1',
      speciesId: 's1',
      nickname: 'Samambaia',
      soilId: 'loamy',
      acquisitionDate: DateTime(2024, 1, 10),
      createdAt: DateTime(2024, 1, 10),
    );
    await pump(tester, plant: original);
    await save(tester, 'Salvar alterações');

    expect(repository.saved.single.nickname, 'Samambaia');
    expect(mutations.created, isEmpty);
  });

  testWidgets('required fields block saving', (tester) async {
    await pump(tester);

    await save(tester, 'Adicionar planta');
    expect(find.text('Informe um apelido'), findsOneWidget);
    expect(find.text('Selecione uma espécie'), findsOneWidget);
    expect(repository.saved, isEmpty);

    // Text typed in the species field without picking an option.
    await tester.enterText(field('Apelido *'), 'Jiboia da sala');
    await tester.enterText(speciesField(), 'Planta qualquer');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await save(tester, 'Adicionar planta');
    expect(find.text('Informe um apelido'), findsNothing);
    expect(find.text('Selecione uma espécie'), findsNothing);
    expect(find.text('Selecione uma espécie da lista'), findsOneWidget);
    expect(repository.saved, isEmpty);
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();

    await pickSpecies(tester, 'jib', 'Jiboia');
    await tester.enterText(field('Frequência de irrigação (dias)'), '0');
    await save(tester, 'Adicionar planta');
    expect(find.text('Informe um número positivo'), findsOneWidget);
    expect(repository.saved, isEmpty);

    // The species has no recommended soil, so it must be picked by hand.
    await tester.enterText(field('Frequência de irrigação (dias)'), '');
    await save(tester, 'Adicionar planta');
    expect(find.text('Selecione um tipo de solo'), findsOneWidget);
    expect(repository.saved, isEmpty);
  });
}
