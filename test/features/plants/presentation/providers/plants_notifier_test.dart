import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/locations/data/locations_repository.dart';
import 'package:polypodium/features/soils/data/soils_repository.dart';
import 'package:polypodium/features/species/data/species_repository.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_providers.dart';
import 'package:polypodium/core/enums.dart';

class MockPlantsRepository extends Mock implements PlantsRepository {}

class MockEntriesRepository extends Mock implements EntriesRepository {}

class MockSpeciesRepository extends Mock implements SpeciesRepository {}

class MockLocationsRepository extends Mock implements LocationsRepository {}

class MockSoilsRepository extends Mock implements SoilsRepository {}

void main() {
  late MockPlantsRepository mockPlantsRepo;
  late MockEntriesRepository mockEntriesRepo;
  late MockSpeciesRepository mockSpeciesRepo;
  late MockLocationsRepository mockLocationsRepo;
  late MockSoilsRepository mockSoilsRepo;
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
    mockSpeciesRepo = MockSpeciesRepository();
    mockLocationsRepo = MockLocationsRepository();
    mockSoilsRepo = MockSoilsRepository();
    when(() => mockSpeciesRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockLocationsRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockSoilsRepo.getAll()).thenAnswer((_) async => [
          SoilModel(id: 'loamy', name: 'Franco', createdAt: DateTime.now()),
        ]);

    container = ProviderContainer(
      overrides: [
        plantsRepositoryProvider.overrideWithValue(mockPlantsRepo),
        entriesRepositoryProvider.overrideWithValue(mockEntriesRepo),
        speciesRepositoryProvider.overrideWithValue(mockSpeciesRepo),
        locationsRepositoryProvider.overrideWithValue(mockLocationsRepo),
        soilsRepositoryProvider.overrideWithValue(mockSoilsRepo),
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

      when(() => mockPlantsRepo.getById('p1')).thenAnswer((_) async => null);
      when(() => mockPlantsRepo.save(any())).thenAnswer((_) async => {});
      when(() => mockEntriesRepo.create(any())).thenAnswer((_) async => {});

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

      when(() => mockPlantsRepo.getById('p1'))
          .thenAnswer((_) async => oldPlant);
      when(() => mockPlantsRepo.save(any())).thenAnswer((_) async => {});
      when(() => mockEntriesRepo.create(any())).thenAnswer((_) async => {});

      final notifier = container.read(plantsNotifierProvider.notifier);
      await notifier.save(newPlant);

      verify(() => mockPlantsRepo.save(newPlant)).called(1);

      final capturedEntry = verify(() => mockEntriesRepo.create(captureAny()))
          .captured
          .single as EntryModel;
      expect(capturedEntry.type, EntryType.history);
      expect(capturedEntry.note, contains('Nickname: Ferny → Ferny Updated'));
    });

    test('setStatus saves the new status and records it in the diary',
        () async {
      final plant = PlantModel(
        id: 'p1',
        speciesId: 's1',
        nickname: 'Ferny',
        soilId: 'loamy',
        acquisitionDate: DateTime(2024, 1, 1),
        createdAt: now,
      );

      when(() => mockPlantsRepo.getById('p1')).thenAnswer((_) async => plant);
      when(() => mockPlantsRepo.save(any())).thenAnswer((_) async => {});
      when(() => mockEntriesRepo.create(any())).thenAnswer((_) async => {});

      await container
          .read(plantsNotifierProvider.notifier)
          .setStatus('p1', PlantStatus.dead);

      final saved = verify(() => mockPlantsRepo.save(captureAny()))
          .captured
          .single as PlantModel;
      expect(saved.status, PlantStatus.dead);
      expect(saved.statusChangedAt, isNotNull);
      expect(saved.nickname, 'Ferny');

      final capturedEntry = verify(() => mockEntriesRepo.create(captureAny()))
          .captured
          .single as EntryModel;
      expect(capturedEntry.type, EntryType.history);
      expect(capturedEntry.note, contains('Status: Active → Dead'));
    });

    test('irrigate calls repository', () async {
      const plantId = 'p1';
      when(() => mockPlantsRepo.irrigate(plantId))
          .thenAnswer((_) async => null);

      final notifier = container.read(plantsNotifierProvider.notifier);
      await notifier.irrigate(plantId);

      verify(() => mockPlantsRepo.irrigate(plantId)).called(1);
    });
  });
}
