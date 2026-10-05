import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/defensivos/data/defensivos_repository.dart';
import 'package:polypodium/features/defensivos/domain/defensivo_model.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/locations/data/locations_repository.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/data/reminders_repository.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';
import 'package:polypodium/features/soils/data/soils_repository.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/species/data/species_repository.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';

class _NoopNotifications implements INotificationService {
  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {}
}

class _NoopPhotoStorage implements PhotoStorage {
  @override
  String get baseDirName => 'test_photos';

  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {}

  @override
  Future<void> deletePhoto(String path) async {}

  @override
  Future<String> savePhoto(dynamic file) async => '';

  @override
  Future<String> savePhotoBytes(List<int> bytes, String fileName) async => '';

  @override
  Future<String> restorePhoto(List<int> bytes, String fileName) async => '';
}

const _device = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

Future<void> _seedPlant(AppDatabase db) async {
  final now = DateTime(2026, 1, 1);
  await SpeciesRepository(db).save(SpeciesModel(
    id: 'species1',
    scientificName: 'Sci',
    popularName: 'Pop',
    defaultIrrigationFrequencyDays: 7,
    recommendedSoilIds: const ['loamy'],
    createdAt: now,
  ));
  await PlantsRepository(db, _NoopNotifications()).save(PlantModel(
    id: 'plant1',
    speciesId: 'species1',
    nickname: 'Samambaia',
    soilId: 'loamy',
    irrigationFrequencyDays: 3,
    acquisitionDate: now,
    createdAt: now,
  ));
}

void main() {
  group('local writes stamp the database deviceId', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: _device);
    });

    tearDown(() async => db.close());

    test('on every synced table, for saves and deletes', () async {
      final now = DateTime(2026, 1, 1);
      await _seedPlant(db);
      await EntriesRepository(db, _NoopPhotoStorage()).create(EntryModel(
        id: 'entry1',
        plantId: 'plant1',
        date: now,
        type: EntryType.observation,
        createdAt: now,
      ));
      await LocationsRepository(db)
          .save(LocationModel(id: 'loc1', name: 'Varanda', createdAt: now));
      await SoilsRepository(db)
          .save(SoilModel(id: 'soil1', name: 'Turfa', createdAt: now));
      await DefensivosRepository(db)
          .save(DefensivoModel(id: 'def1', name: 'Neem', createdAt: now));
      await RemindersRepository(db).save(ReminderModel(
        id: 'rem1',
        plantId: 'plant1',
        entryType: EntryType.fertilizer,
        intervalDays: 30,
        createdAt: now,
      ));

      expect((await db.speciesDao.getById('species1'))!.deviceId, _device);
      expect((await db.plantsDao.getById('plant1'))!.deviceId, _device);
      expect((await db.entriesDao.getById('entry1'))!.deviceId, _device);
      expect((await db.locationsDao.getById('loc1'))!.deviceId, _device);
      expect((await db.soilsDao.getSoilById('soil1'))!.deviceId, _device);
      expect(
          (await db.defensivosDao.getDefensivoById('def1'))!.deviceId, _device);
      expect((await db.remindersDao.getById('rem1'))!.deviceId, _device);

      // A pulled row records its sender; a local delete takes it back.
      await (db.update(db.locationsTable)..where((t) => t.id.equals('loc1')))
          .write(const LocationsTableCompanion(
              deviceId: Value('1b4e28ba-2fa1-41d2-883f-0016d3cca427')));
      await LocationsRepository(db).delete('loc1');
      final deleted = await db.locationsDao.getById('loc1');
      expect(deleted!.deletedAt, isNotNull);
      expect(deleted.deviceId, _device);
    });

    test('on the derived plant write after an irrigation entry', () async {
      await _seedPlant(db);
      await (db.update(db.plantsTable)..where((t) => t.id.equals('plant1')))
          .write(const PlantsTableCompanion(deviceId: Value(null)));

      final now = DateTime(2026, 1, 2);
      await EntriesRepository(db, _NoopPhotoStorage()).create(EntryModel(
        id: 'entry1',
        plantId: 'plant1',
        date: now,
        type: EntryType.irrigation,
        createdAt: now,
      ));
      await PlantsRepository(db, _NoopNotifications())
          .refreshPlantStatus('plant1', reschedule: false);

      final plant = await db.plantsDao.getById('plant1');
      expect(plant!.lastIrrigatedAt, now);
      expect(plant.deviceId, _device);
    });

    test('stores null without a device (local workspace)', () async {
      final local = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(local.close);
      await _seedPlant(local);
      expect((await local.plantsDao.getById('plant1'))!.deviceId, isNull);
    });
  });

  test('the background "Watered" action stamps the workspace deviceId',
      () async {
    final dir = await Directory.systemTemp.createTemp('device_id_stamping');
    addTearDown(() => dir.delete(recursive: true));
    final workspace = Workspace(
      id: 'ws1',
      name: 'Servidor',
      type: WorkspaceType.remote,
      deviceId: _device,
      createdAt: DateTime(2026, 1, 1),
    );
    final db = NotificationService.openIsolateDatabase(
        File('${dir.path}/ws.db'), workspace);
    addTearDown(db.close);
    await _seedPlant(db);
    await (db.update(db.plantsTable)..where((t) => t.id.equals('plant1')))
        .write(const PlantsTableCompanion(deviceId: Value(null)));

    await NotificationService.recordWatered(db, workspace, ['plant1']);

    final entries = await db.entriesDao.getAll();
    expect(entries.single.type, EntryType.irrigation);
    expect(entries.single.deviceId, _device);
    expect((await db.plantsDao.getById('plant1'))!.deviceId, _device);
  });
}
