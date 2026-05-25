import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/species/data/species_repository.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:uuid/uuid.dart';

class MockPhotoStorage implements PhotoStorage {
  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {}

  @override
  Future<void> deletePhoto(String path) async {}

  @override
  Future<String> savePhoto(dynamic file) async => '';
}

class MockNotificationService implements INotificationService {
  @override
  Future<void> schedule(
          {required PlantModel plant, required SpeciesModel species}) async {}

  @override
  Future<void> cancel(String plantId) async {}
}

void main() {
  late AppDatabase db;
  late SpeciesRepository speciesRepo;
  late PlantsRepository plantsRepo;
  late EntriesRepository entriesRepo;
  late MockPhotoStorage mockPhotoStorage;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    speciesRepo = SpeciesRepository(db);
    plantsRepo = PlantsRepository(db, MockNotificationService(),
        speciesRepo: speciesRepo);
    mockPhotoStorage = MockPhotoStorage();
    entriesRepo = EntriesRepository(db, mockPhotoStorage);

    // Create a default species for tests
    await speciesRepo.save(SpeciesModel(
      id: 'species1',
      scientificName: 'Test Scientific',
      popularName: 'Test Popular',
      defaultIrrigationFrequencyDays: 7,
      recommendedSoilTypes: [SoilType.loamy],
      createdAt: DateTime.now(),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  test('refreshPlantStatus updates lastIrrigatedAt based on latest entry',
      () async {
    final plantId = const Uuid().v4();
    final plant = PlantModel(
      id: plantId,
      speciesId: 'species1',
      nickname: 'Test Plant',
      soilType: SoilType.loamy,
      acquisitionDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await plantsRepo.save(plant);

    // Initial state: lastIrrigatedAt is null
    var updatedPlant = await plantsRepo.getById(plantId);
    expect(updatedPlant?.lastIrrigatedAt, isNull);

    // Add an irrigation entry
    final date1 = DateTime(2023, 1, 1);
    final entry1 = EntryModel(
      id: const Uuid().v4(),
      plantId: plantId,
      date: date1,
      type: EntryType.irrigation,
      createdAt: DateTime.now(),
    );
    await entriesRepo.create(entry1);

    // Manually refresh status (as we would in the notifier)
    await plantsRepo.refreshPlantStatus(plantId);
    updatedPlant = await plantsRepo.getById(plantId);
    expect(updatedPlant?.lastIrrigatedAt, date1);

    // Add a newer irrigation entry
    final date2 = DateTime(2023, 1, 5);
    final entry2 = EntryModel(
      id: const Uuid().v4(),
      plantId: plantId,
      date: date2,
      type: EntryType.irrigation,
      createdAt: DateTime.now(),
    );
    await entriesRepo.create(entry2);

    await plantsRepo.refreshPlantStatus(plantId);
    updatedPlant = await plantsRepo.getById(plantId);
    expect(updatedPlant?.lastIrrigatedAt, date2);

    // Delete the latest entry
    await entriesRepo.delete(entry2.id);
    await plantsRepo.refreshPlantStatus(plantId);
    updatedPlant = await plantsRepo.getById(plantId);
    expect(updatedPlant?.lastIrrigatedAt, date1);

    // Delete the last entry
    await entriesRepo.delete(entry1.id);
    await plantsRepo.refreshPlantStatus(plantId);
    updatedPlant = await plantsRepo.getById(plantId);
    expect(updatedPlant?.lastIrrigatedAt, isNull);
  });

  test('History entries cannot be deleted', () async {
    final plantId = const Uuid().v4();
    final entry = EntryModel(
      id: const Uuid().v4(),
      plantId: plantId,
      date: DateTime.now(),
      type: EntryType.history,
      createdAt: DateTime.now(),
    );

    await entriesRepo.create(entry);

    expect(
      () => entriesRepo.delete(entry.id),
      throwsA(isA<Exception>()
          .having((e) => e.toString(), 'message', contains('histórico'))),
    );

    final savedEntry = await entriesRepo.getById(entry.id);
    expect(savedEntry, isNotNull);
  });
}
