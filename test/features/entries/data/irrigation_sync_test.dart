import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:plantlog/core/database/app_database.dart';
import 'package:plantlog/core/enums.dart';
import 'package:plantlog/features/plants/data/plants_repository.dart';
import 'package:plantlog/features/entries/data/entries_repository.dart';
import 'package:plantlog/features/entries/domain/entry_model.dart';
import 'package:plantlog/features/plants/domain/plant_model.dart';
import 'package:plantlog/core/storage/photo_storage.dart';
import 'package:uuid/uuid.dart';

class MockPhotoStorage implements PhotoStorage {
  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {}

  @override
  Future<void> deletePhoto(String path) async {}

  @override
  Future<String> savePhoto(dynamic file) async => '';
}

void main() {
  late AppDatabase db;
  late PlantsRepository plantsRepo;
  late EntriesRepository entriesRepo;
  late MockPhotoStorage mockPhotoStorage;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    plantsRepo = PlantsRepository(db);
    mockPhotoStorage = MockPhotoStorage();
    entriesRepo = EntriesRepository(db, mockPhotoStorage);
  });

  tearDown(() async {
    await db.close();
  });

  test('refreshPlantStatus updates lastIrrigatedAt based on latest entry', () async {
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
}
