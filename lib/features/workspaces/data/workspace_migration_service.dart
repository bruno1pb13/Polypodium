import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/storage/photo_storage.dart';
import '../domain/workspace_model.dart';
import '../domain/workspace_paths.dart';

/// Copies data created in the local (device-only) workspace into a
/// newly-created remote workspace, so it can be pushed to a server the user
/// just registered on. A local workspace can never call sync() (isLoggedIn
/// requires `type == remote`), so every *active* row in it is fair game to
/// migrate; only default-seeded soils (never touched by the user) are
/// skipped, via [SoilsTable.isSeeded].
class WorkspaceMigrationService {
  const WorkspaceMigrationService();

  /// Whether the local workspace has any data worth offering to migrate.
  /// [local] must be the actual persisted local workspace (see note on
  /// [migrateLocalInto]).
  Future<bool> hasPendingLocalData(Workspace local) async {
    final db = AppDatabase(fileName: dbFileNameFor(local));
    try {
      return await hasPendingData(db);
    } finally {
      await db.close();
    }
  }

  /// Core of [hasPendingLocalData], split out so it can be exercised in
  /// tests against an in-memory database instead of a real file.
  Future<bool> hasPendingData(AppDatabase db) async {
    if ((await db.speciesDao.getAll()).isNotEmpty) return true;
    if ((await db.soilsDao.getAllSoils()).any((s) => !s.isSeeded)) return true;
    if ((await db.locationsDao.getAll()).isNotEmpty) return true;
    if ((await db.plantsDao.getAll()).isNotEmpty) return true;
    if ((await db.entriesDao.getAll()).isNotEmpty) return true;
    return false;
  }

  /// [local] must be the actual persisted local workspace (not a fresh
  /// `Workspace.newLocal()`), since a pre-existing install may have a
  /// `dbFileNameOverride` pointing at legacy storage.
  Future<void> migrateLocalInto({
    required Workspace local,
    required AppDatabase targetDb,
    required PhotoStorage targetPhotos,
  }) async {
    final sourceDb = AppDatabase(fileName: dbFileNameFor(local));
    try {
      await migrateData(
        sourceDb: sourceDb,
        targetDb: targetDb,
        targetPhotos: targetPhotos,
      );
    } finally {
      await sourceDb.close();
    }
  }

  /// Core of [migrateLocalInto], split out so it can be exercised in tests
  /// against in-memory databases instead of real files.
  Future<void> migrateData({
    required AppDatabase sourceDb,
    required AppDatabase targetDb,
    required PhotoStorage targetPhotos,
  }) async {
    await _migrateSpecies(sourceDb, targetDb);
    await _migrateSoils(sourceDb, targetDb);
    await _migrateLocations(sourceDb, targetDb);
    await _migratePlants(sourceDb, targetDb);
    await _migrateEntries(sourceDb, targetDb, targetPhotos);
  }

  Future<void> _migrateSpecies(AppDatabase source, AppDatabase target) async {
    for (final row in await source.speciesDao.getAll()) {
      await target.transaction(() async {
        final rev = await target.syncMetaDao.nextRev();
        await target.speciesDao.upsert(SpeciesTableCompanion.insert(
          id: row.id,
          scientificName: row.scientificName,
          popularName: row.popularName,
          defaultIrrigationFrequencyDays:
              Value(row.defaultIrrigationFrequencyDays),
          recommendedSoilTypes: row.recommendedSoilTypes,
          createdAt: row.createdAt,
          updatedAt: DateTime.now(),
          localRev: Value(rev),
        ));
      });
    }
  }

  Future<void> _migrateSoils(AppDatabase source, AppDatabase target) async {
    for (final row in await source.soilsDao.getAllSoils()) {
      if (row.isSeeded) continue;
      await target.transaction(() async {
        final rev = await target.syncMetaDao.nextRev();
        await target.soilsDao.insertSoil(SoilsTableCompanion.insert(
          id: row.id,
          name: row.name,
          composition: Value(row.composition),
          imagePath: Value(row.imagePath),
          imageSource: Value(row.imageSource),
          createdAt: row.createdAt,
          updatedAt: DateTime.now(),
          localRev: Value(rev),
          isSeeded: const Value(false),
        ));
      });
    }
  }

  Future<void> _migrateLocations(
      AppDatabase source, AppDatabase target) async {
    for (final row in await source.locationsDao.getAll()) {
      await target.transaction(() async {
        final rev = await target.syncMetaDao.nextRev();
        await target.locationsDao.upsert(LocationsTableCompanion.insert(
          id: row.id,
          name: row.name,
          description: Value(row.description),
          latitude: Value(row.latitude),
          longitude: Value(row.longitude),
          createdAt: row.createdAt,
          updatedAt: DateTime.now(),
          localRev: Value(rev),
        ));
      });
    }
  }

  Future<void> _migratePlants(AppDatabase source, AppDatabase target) async {
    for (final row in await source.plantsDao.getAll()) {
      await target.transaction(() async {
        final rev = await target.syncMetaDao.nextRev();
        await target.plantsDao.upsert(PlantsTableCompanion.insert(
          id: row.id,
          speciesId: row.speciesId,
          nickname: row.nickname,
          soilType: row.soilType,
          irrigationFrequencyDays: Value(row.irrigationFrequencyDays),
          acquisitionDate: row.acquisitionDate,
          location: Value(row.location),
          locationId: Value(row.locationId),
          lastIrrigatedAt: Value(row.lastIrrigatedAt),
          createdAt: row.createdAt,
          updatedAt: DateTime.now(),
          localRev: Value(rev),
        ));
      });
    }
  }

  /// Copies each entry's photo file into [targetPhotos] before inserting, so
  /// the migrated row points at a file that actually exists in the new
  /// workspace's photo directory rather than the old one.
  Future<void> _migrateEntries(
    AppDatabase source,
    AppDatabase target,
    PhotoStorage targetPhotos,
  ) async {
    for (final row in await source.entriesDao.getAll()) {
      String? photoPath;
      if (row.photoPath != null) {
        final file = File(row.photoPath!);
        if (await file.exists()) {
          photoPath = await targetPhotos.savePhoto(file);
        }
      }

      await target.transaction(() async {
        final rev = await target.syncMetaDao.nextRev();
        await target.entriesDao.insert(EntriesTableCompanion.insert(
          id: row.id,
          plantId: row.plantId,
          date: row.date,
          photoPath: Value(photoPath),
          note: Value(row.note),
          type: row.type,
          numericValue: Value(row.numericValue),
          extraData: Value(row.extraData),
          createdAt: row.createdAt,
          updatedAt: DateTime.now(),
          localRev: Value(rev),
        ));
      });
    }
  }
}
