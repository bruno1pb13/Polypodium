import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_providers.dart';
import 'package:polypodium/core/enums.dart';

class MockPlantsRepository extends Mock implements PlantsRepository {}

class MockEntriesRepository extends Mock implements EntriesRepository {}

// Simple mocks for notifiers
class MockSpeciesNotifier extends SpeciesNotifier with Mock {
  @override
  Stream<List<SpeciesModel>> build() => Stream.value([]);
}

class MockLocationsNotifier extends LocationsNotifier with Mock {
  @override
  Stream<List<LocationModel>> build() => Stream.value([]);
}

class MockSoilsNotifier extends SoilsNotifier with Mock {
  @override
  Stream<List<SoilModel>> build() => Stream.value([
        SoilModel(id: 'loamy', name: 'Franco', createdAt: DateTime.now()),
      ]);
}

class MockEntriesNotifier extends EntriesNotifier with Mock {
  @override
  Stream<List<EntryModel>> build(String plantId) => Stream.value([]);
}

void main() {
  late MockPlantsRepository mockPlantsRepo;
  late MockEntriesRepository mockEntriesRepo;
  late ProviderContainer container;

  final now = DateTime.now();
  final dummyEntry = EntryModel(
    id: 'dummy',
    plantId: 'plant1',
    date: now,
    type: EntryType.history,
    createdAt: now,
  );

  setUpAll(() {
    registerFallbackValue(dummyEntry);
    registerFallbackValue(PlantModel(
      id: '',
      speciesId: '',
      nickname: '',
      soilId: 'loamy',
      acquisitionDate: now,
      createdAt: now,
    ));
  });

  setUp(() {
    mockPlantsRepo = MockPlantsRepository();
    mockEntriesRepo = MockEntriesRepository();

    container = ProviderContainer(
      overrides: [
        plantsRepositoryProvider.overrideWithValue(mockPlantsRepo),
        entriesRepositoryProvider.overrideWithValue(mockEntriesRepo),
        speciesNotifierProvider.overrideWith(() => MockSpeciesNotifier()),
        locationsNotifierProvider.overrideWith(() => MockLocationsNotifier()),
        soilsNotifierProvider.overrideWith(() => MockSoilsNotifier()),
        // For family providers, we need to override the specific instance or use the whole family
        // entriesNotifierProvider.overrideWith((p) => MockEntriesNotifier()) is not correct for riverpod_generator
        // We can override each call or use a different strategy.
        // Let's try to override the family with a provider that returns our mock.
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PlantsNotifier', () {
    test('save creates history entry when plant is new', () async {
      final plant = PlantModel(
        id: 'p1',
        speciesId: 's1',
        nickname: 'Ferny',
        soilId: 'loamy',
        acquisitionDate: DateTime(2024, 1, 1),
        createdAt: now,
      );

      when(() => mockPlantsRepo.watchAll()).thenAnswer((_) => Stream.value([]));
      when(() => mockPlantsRepo.save(any())).thenAnswer((_) async => {});
      when(() => mockEntriesRepo.create(any())).thenAnswer((_) async => {});

      // For history creation, PlantsNotifier calls entriesNotifierProvider(plant.id).notifier.create
      // So we need to ensure that notifier is available.
      // We can override the provider for this specific ID.
      container = ProviderContainer(
        overrides: [
          plantsRepositoryProvider.overrideWithValue(mockPlantsRepo),
          entriesRepositoryProvider.overrideWithValue(mockEntriesRepo),
          speciesNotifierProvider.overrideWith(() => MockSpeciesNotifier()),
          locationsNotifierProvider.overrideWith(() => MockLocationsNotifier()),
          soilsNotifierProvider.overrideWith(() => MockSoilsNotifier()),
          entriesNotifierProvider('p1')
              .overrideWith(() => MockEntriesNotifier()),
        ],
      );
      container.listen(plantsNotifierProvider, (_, __) {});
      container.listen(speciesNotifierProvider, (_, __) {});
      container.listen(locationsNotifierProvider, (_, __) {});
      container.listen(soilsNotifierProvider, (_, __) {});

      final notifier = container.read(plantsNotifierProvider.notifier);
      await notifier.save(plant);

      verify(() => mockPlantsRepo.save(plant)).called(1);

      final capturedEntry = verify(() => mockEntriesRepo.create(captureAny()))
          .captured
          .single as EntryModel;
      expect(capturedEntry.type, EntryType.history);
      expect(capturedEntry.plantId, plant.id);
      // History notes are written via systemL10n(); in the test environment
      // the device locale resolves to the English fallback.
      expect(capturedEntry.note, contains('Plant added'));
      expect(capturedEntry.note, contains('Ferny'));
    });

    test('save creates history entry when plant is updated', () async {
      final oldPlant = PlantModel(
        id: 'p1',
        speciesId: 's1',
        nickname: 'Ferny',
        soilId: 'loamy',
        acquisitionDate: DateTime(2024, 1, 1),
        createdAt: now,
      );

      final newPlant = oldPlant.copyWith(nickname: 'Ferny Updated');

      when(() => mockPlantsRepo.watchAll())
          .thenAnswer((_) => Stream.value([oldPlant]));
      when(() => mockPlantsRepo.save(any())).thenAnswer((_) async => {});
      when(() => mockEntriesRepo.create(any())).thenAnswer((_) async => {});

      container = ProviderContainer(
        overrides: [
          plantsRepositoryProvider.overrideWithValue(mockPlantsRepo),
          entriesRepositoryProvider.overrideWithValue(mockEntriesRepo),
          speciesNotifierProvider.overrideWith(() => MockSpeciesNotifier()),
          locationsNotifierProvider.overrideWith(() => MockLocationsNotifier()),
          soilsNotifierProvider.overrideWith(() => MockSoilsNotifier()),
          entriesNotifierProvider('p1')
              .overrideWith(() => MockEntriesNotifier()),
        ],
      );
      container.listen(plantsNotifierProvider, (_, __) {});
      container.listen(speciesNotifierProvider, (_, __) {});
      container.listen(locationsNotifierProvider, (_, __) {});
      container.listen(soilsNotifierProvider, (_, __) {});

      final notifier = container.read(plantsNotifierProvider.notifier);
      // Wait for initial build to populate the "oldPlants" state
      await container.read(plantsNotifierProvider.future);

      await notifier.save(newPlant);

      verify(() => mockPlantsRepo.save(newPlant)).called(1);

      final capturedEntry = verify(() => mockEntriesRepo.create(captureAny()))
          .captured
          .single as EntryModel;
      expect(capturedEntry.type, EntryType.history);
      expect(capturedEntry.note, contains('Nickname: Ferny → Ferny Updated'));
    });

    test('irrigate calls repository', () async {
      const plantId = 'p1';
      when(() => mockPlantsRepo.irrigate(plantId))
          .thenAnswer((_) async => null);
      when(() => mockPlantsRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));

      final notifier = container.read(plantsNotifierProvider.notifier);
      await notifier.irrigate(plantId);

      verify(() => mockPlantsRepo.irrigate(plantId)).called(1);
    });
  });
}
