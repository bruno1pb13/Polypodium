import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/workspaces/data/workspace_migration_service.dart';

class FakePhotoStorage implements PhotoStorage {
  FakePhotoStorage(this.targetDir);
  final Directory targetDir;

  @override
  String get baseDirName => 'test_photos';

  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {}

  @override
  Future<void> deletePhoto(String path) async {}

  @override
  Future<String> savePhoto(File sourceFile) async {
    final dest =
        File(p.join(targetDir.path, 'migrated_${p.basename(sourceFile.path)}'));
    await sourceFile.copy(dest.path);
    return dest.path;
  }

  @override
  Future<String> savePhotoBytes(List<int> bytes, String fileName) async => '';

  @override
  Future<String> restorePhoto(List<int> bytes, String fileName) async => '';
}

void main() {
  late AppDatabase source;
  late AppDatabase target;
  const service = WorkspaceMigrationService();

  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    target = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<void> addLocation(AppDatabase db, String id) =>
      db.locationsDao.upsert(LocationsTableCompanion.insert(
        id: id,
        name: 'Location $id',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

  group('hasPendingData', () {
    test('false for a freshly-created database (only seeded soils)',
        () async {
      expect(await service.hasPendingData(source), isFalse);
    });

    test('true once any entity exists', () async {
      await addLocation(source, 'loc1');
      expect(await service.hasPendingData(source), isTrue);
    });

    test('true once a non-seeded (user-created) soil exists', () async {
      await source.soilsDao.insertSoil(SoilsTableCompanion.insert(
        id: 'custom-soil',
        name: 'Minha mistura',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isSeeded: const Value(false),
      ));
      expect(await service.hasPendingData(source), isTrue);
    });
  });

  group('migrateData', () {
    test('stamps the remote workspace deviceId on the copied rows',
        () async {
      final remote = AppDatabase.forTesting(NativeDatabase.memory(),
          deviceId: 'remote-device');
      addTearDown(remote.close);
      await addLocation(source, 'loc1');

      await service.migrateData(
        sourceDb: source,
        targetDb: remote,
        targetPhotos: FakePhotoStorage(await Directory.systemTemp.createTemp()),
      );

      expect((await remote.locationsDao.getById('loc1'))!.deviceId,
          'remote-device');
    });

    test('copies locations but skips already-seeded default soils',
        () async {
      await addLocation(source, 'loc1');

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(await Directory.systemTemp.createTemp()),
      );

      final locations = await target.locationsDao.getAll();
      expect(locations.map((l) => l.id), contains('loc1'));

      // Default soils are seeded (isSeeded=true) in both databases, so they
      // must not be duplicated/overwritten by the migration.
      final soils = await target.soilsDao.getAllSoils();
      final seededCount = soils.where((s) => s.isSeeded).length;
      expect(seededCount, soils.length);
    });

    test('migrates a custom soil created by the user', () async {
      await source.soilsDao.insertSoil(SoilsTableCompanion.insert(
        id: 'custom-soil',
        name: 'Minha mistura',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isSeeded: const Value(false),
      ));

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(await Directory.systemTemp.createTemp()),
      );

      final soil = await target.soilsDao.getSoilById('custom-soil');
      expect(soil, isNotNull);
      expect(soil!.name, 'Minha mistura');
      expect(soil.isSeeded, isFalse);
    });

    test('migrates species, plants and entries in dependency order',
        () async {
      await source.speciesDao.upsert(SpeciesTableCompanion.insert(
        id: 'species1',
        scientificName: 'Sci',
        popularName: 'Pop',
        recommendedSoilTypes: const [],
        light: const Value(LightRequirement.partialShade),
        humidity: const Value(HumidityLevel.high),
        petToxicity: const Value(PetToxicity.toxic),
        floweringMonths: const Value({3, 4}),
        careNotes: const Value('Borrifar'),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
      await source.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        status: const Value(PlantStatus.archived),
        statusChangedAt: Value(DateTime(2026, 1, 3)),
        parentPlantId: const Value('mother'),
        coverPhotoId: const Value('entry1'),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
      await source.entriesDao.insert(EntriesTableCompanion.insert(
        id: 'entry1',
        plantId: 'plant1',
        date: DateTime(2026, 1, 2),
        type: EntryType.observation,
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      ));

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(await Directory.systemTemp.createTemp()),
      );

      final species = await target.speciesDao.getById('species1');
      final plant = await target.plantsDao.getById('plant1');
      final entry = await target.entriesDao.getById('entry1');

      expect(species, isNotNull);
      expect(species!.light, LightRequirement.partialShade);
      expect(species.humidity, HumidityLevel.high);
      expect(species.petToxicity, PetToxicity.toxic);
      expect(species.floweringMonths, {3, 4});
      expect(species.careNotes, 'Borrifar');
      expect(plant, isNotNull);
      expect(plant!.status, PlantStatus.archived);
      expect(plant.statusChangedAt, DateTime(2026, 1, 3));
      expect(plant.parentPlantId, 'mother');
      expect(plant.coverPhotoId, 'entry1');
      expect(entry, isNotNull);
    });

    test('migrates reminders and skips deleted ones', () async {
      await source.speciesDao.upsert(SpeciesTableCompanion.insert(
        id: 'species1',
        scientificName: 'Sci',
        popularName: 'Pop',
        recommendedSoilTypes: const [],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
      await source.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
      for (final (id, deletedAt) in [
        ('rem1', null),
        ('rem2', DateTime(2026, 1, 5)),
      ]) {
        await source.remindersDao.upsert(RemindersTableCompanion.insert(
          id: id,
          plantId: 'plant1',
          entryType: EntryType.pruning,
          intervalDays: 60,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          deletedAt: Value(deletedAt),
        ));
      }
      expect(await service.hasPendingData(source), isTrue);

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(await Directory.systemTemp.createTemp()),
      );

      final migrated = await target.remindersDao.getById('rem1');
      expect(migrated?.entryType, EntryType.pruning);
      expect(migrated?.intervalDays, 60);
      expect(migrated!.localRev, greaterThan(0));
      expect(await target.remindersDao.getById('rem2'), isNull);
    });

    test('copies an entry photo file and rewrites photoPath to the new '
        'workspace storage', () async {
      final sourcePhotoDir = await Directory.systemTemp.createTemp();
      final targetPhotoDir = await Directory.systemTemp.createTemp();
      final sourcePhoto = File(p.join(sourcePhotoDir.path, 'photo.jpg'));
      await sourcePhoto.writeAsBytes([1, 2, 3]);

      await source.speciesDao.upsert(SpeciesTableCompanion.insert(
        id: 'species1',
        scientificName: 'Sci',
        popularName: 'Pop',
        recommendedSoilTypes: const [],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
      await source.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
      await source.entriesDao.insert(EntriesTableCompanion.insert(
        id: 'entry1',
        plantId: 'plant1',
        date: DateTime(2026, 1, 2),
        photoPath: Value(sourcePhoto.path),
        type: EntryType.observation,
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      ));

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(targetPhotoDir),
      );

      final entry = await target.entriesDao.getById('entry1');
      expect(entry!.photoPath, isNotNull);
      expect(entry.photoPath, isNot(sourcePhoto.path));
      expect(await File(entry.photoPath!).exists(), isTrue);
    });

    test('copies the extra photos of an entry', () async {
      final sourcePhotoDir = await Directory.systemTemp.createTemp();
      final targetPhotoDir = await Directory.systemTemp.createTemp();
      Future<String> photo(String name) async {
        final file = File(p.join(sourcePhotoDir.path, name));
        await file.writeAsBytes([1]);
        return file.path;
      }

      await source.entriesDao.insert(EntriesTableCompanion.insert(
        id: 'entry1',
        plantId: 'plant1',
        date: DateTime(2026, 1, 2),
        photoPath: Value(await photo('a.jpg')),
        type: EntryType.observation,
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      ));
      for (final (id, name, deletedAt) in [
        ('ph2', 'b.jpg', null),
        ('ph3', 'c.jpg', DateTime(2026, 1, 3)),
      ]) {
        await source.entryPhotosDao.upsert(EntryPhotosTableCompanion.insert(
          id: id,
          entryId: 'entry1',
          photoPath: await photo(name),
          position: const Value(1),
          createdAt: DateTime(2026, 1, 2),
          updatedAt: DateTime(2026, 1, 2),
          deletedAt: Value(deletedAt),
        ));
      }

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(targetPhotoDir),
      );

      final migrated = await target.entryPhotosDao.getById('ph2');
      expect(migrated!.entryId, 'entry1');
      expect(p.dirname(migrated.photoPath), targetPhotoDir.path);
      expect(await File(migrated.photoPath).exists(), isTrue);
      expect(migrated.localRev, greaterThan(0));
      expect(await target.entryPhotosDao.getById('ph3'), isNull);
    });
  });
}
