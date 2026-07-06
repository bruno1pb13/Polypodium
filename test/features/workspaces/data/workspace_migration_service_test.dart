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

  Future<void> addPendingLocation(AppDatabase db, String id) =>
      db.locationsDao.upsert(LocationsTableCompanion.insert(
        id: id,
        name: 'Location $id',
        createdAt: DateTime(2026, 1, 1),
        syncStatus: const Value(SyncStatus.pending),
      ));

  group('hasPendingData', () {
    test('false for a freshly-created database (only seeded soils)',
        () async {
      expect(await service.hasPendingData(source), isFalse);
    });

    test('true once any entity has syncStatus pending', () async {
      await addPendingLocation(source, 'loc1');
      expect(await service.hasPendingData(source), isTrue);
    });
  });

  group('migrateData', () {
    test('copies pending locations but skips already-seeded default soils',
        () async {
      await addPendingLocation(source, 'loc1');

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(await Directory.systemTemp.createTemp()),
      );

      final locations = await target.locationsDao.getAll();
      expect(locations.map((l) => l.id), contains('loc1'));

      // Default soils are seeded with syncStatus=synced in both databases,
      // so they must not be duplicated/overwritten by the migration.
      final soils = await target.soilsDao.getAllSoils();
      final seededCount =
          soils.where((s) => s.syncStatus == SyncStatus.synced).length;
      expect(seededCount, soils.length);
    });

    test('migrates a custom soil created by the user', () async {
      await source.soilsDao.insertSoil(SoilsTableCompanion.insert(
        id: 'custom-soil',
        name: 'Minha mistura',
        createdAt: DateTime(2026, 1, 1),
        syncStatus: const Value(SyncStatus.pending),
      ));

      await service.migrateData(
        sourceDb: source,
        targetDb: target,
        targetPhotos: FakePhotoStorage(await Directory.systemTemp.createTemp()),
      );

      final soil = await target.soilsDao.getSoilById('custom-soil');
      expect(soil, isNotNull);
      expect(soil!.name, 'Minha mistura');
      expect(soil.syncStatus, SyncStatus.pending);
    });

    test('migrates species, plants and entries in dependency order and '
        'marks them pending for the next sync', () async {
      await source.speciesDao.upsert(SpeciesTableCompanion.insert(
        id: 'species1',
        scientificName: 'Sci',
        popularName: 'Pop',
        recommendedSoilTypes: const [],
        createdAt: DateTime(2026, 1, 1),
        syncStatus: const Value(SyncStatus.pending),
      ));
      await source.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        syncStatus: const Value(SyncStatus.pending),
      ));
      await source.entriesDao.insert(EntriesTableCompanion.insert(
        id: 'entry1',
        plantId: 'plant1',
        date: DateTime(2026, 1, 2),
        type: EntryType.observation,
        createdAt: DateTime(2026, 1, 2),
        syncStatus: const Value(SyncStatus.pending),
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
      expect(plant, isNotNull);
      expect(entry, isNotNull);
      expect(species!.syncStatus, SyncStatus.pending);
      expect(plant!.syncStatus, SyncStatus.pending);
      expect(entry!.syncStatus, SyncStatus.pending);
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
        syncStatus: const Value(SyncStatus.pending),
      ));
      await source.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        syncStatus: const Value(SyncStatus.pending),
      ));
      await source.entriesDao.insert(EntriesTableCompanion.insert(
        id: 'entry1',
        plantId: 'plant1',
        date: DateTime(2026, 1, 2),
        photoPath: Value(sourcePhoto.path),
        type: EntryType.observation,
        createdAt: DateTime(2026, 1, 2),
        syncStatus: const Value(SyncStatus.pending),
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
  });
}
