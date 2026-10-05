import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/data_transfer/data/data_export_service.dart';
import 'package:polypodium/features/data_transfer/data/data_import_service.dart';

class FakePhotoStorage implements PhotoStorage {
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
  Future<String> restorePhoto(List<int> bytes, String fileName) async =>
      '/restored/$fileName';
}

void main() {
  late AppDatabase source;
  late AppDatabase target;

  final t0 = DateTime(2026, 1, 1);
  final t1 = DateTime(2026, 2, 1);

  Future<void> seedSpecies(AppDatabase db, String name, DateTime updatedAt,
      {DateTime? deletedAt, int rev = 1}) async {
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: name,
      popularName: 'Popular',
      recommendedSoilTypes: const ['loamy'],
      createdAt: t0,
      updatedAt: updatedAt,
      deletedAt: Value(deletedAt),
      localRev: Value(rev),
    ));
  }

  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    target = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('exported backup round-trips into an empty workspace', () async {
    await seedSpecies(source, 'Ficus lyrata', t0);
    await source.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Minha planta',
      soilType: 'loamy',
      acquisitionDate: t0,
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(2),
    ));
    await source.entriesDao.insert(EntriesTableCompanion.insert(
      id: 'entry1',
      plantId: 'plant1',
      date: t0,
      type: EntryType.irrigation,
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(3),
    ));

    final bytes = await DataExportService(source).buildArchiveBytes();
    final summary = await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final species = await target.speciesDao.getById('species1');
    final plant = await target.plantsDao.getById('plant1');
    final entry = await target.entriesDao.getById('entry1');

    expect(species?.scientificName, 'Ficus lyrata');
    expect(plant?.nickname, 'Minha planta');
    expect(entry?.type, EntryType.irrigation);
    // Every applied row must carry a fresh localRev so it gets pushed to the
    // server on the next sync.
    expect(species!.localRev, greaterThan(0));
    expect(summary.applied, greaterThanOrEqualTo(3));

    // Imported irrigation entries recompute the derived lastIrrigatedAt.
    expect(plant!.lastIrrigatedAt, t0);
  });

  test('importing an older backup row never overwrites newer local data',
      () async {
    await seedSpecies(source, 'Nome antigo', t0);
    final bytes = await DataExportService(source).buildArchiveBytes();

    await seedSpecies(target, 'Nome novo', t1);
    final summary = await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final species = await target.speciesDao.getById('species1');
    expect(species?.scientificName, 'Nome novo');
    expect(summary.skipped, greaterThanOrEqualTo(1));
  });

  test('tombstones survive the round trip', () async {
    await seedSpecies(source, 'Apagada', t1, deletedAt: t1);
    final bytes = await DataExportService(source).buildArchiveBytes();

    await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final species = await target.speciesDao.getById('species1');
    expect(species, isNotNull);
    expect(species!.deletedAt, t1);
  });

  test('plant status survives the round trip', () async {
    await seedSpecies(source, 'Ficus lyrata', t0);
    await source.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Doada',
      soilType: 'loamy',
      acquisitionDate: t0,
      status: const Value(PlantStatus.donated),
      statusChangedAt: Value(t1),
      parentPlantId: const Value('mother'),
      coverPhotoId: const Value('entry1'),
      createdAt: t0,
      updatedAt: t1,
      localRev: const Value(2),
    ));

    final bytes = await DataExportService(source).buildArchiveBytes();
    await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final plant = await target.plantsDao.getById('plant1');
    expect(plant!.status, PlantStatus.donated);
    expect(plant.statusChangedAt, t1);
    expect(plant.parentPlantId, 'mother');
    expect(plant.coverPhotoId, 'entry1');
  });

  test('the species care sheet survives the round trip', () async {
    await source.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: 'Dieffenbachia seguine',
      popularName: 'Comigo-ninguém-pode',
      recommendedSoilTypes: const [],
      light: const Value(LightRequirement.partialShade),
      humidity: const Value(HumidityLevel.high),
      petToxicity: const Value(PetToxicity.toxic),
      floweringMonths: const Value({9, 10}),
      careNotes: const Value('Seiva irritante'),
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(1),
    ));

    final bytes = await DataExportService(source).buildArchiveBytes();
    await DataImportService(target, FakePhotoStorage()).importFromBytes(bytes);

    final species = await target.speciesDao.getById('species1');
    expect(species!.light, LightRequirement.partialShade);
    expect(species.humidity, HumidityLevel.high);
    expect(species.petToxicity, PetToxicity.toxic);
    expect(species.floweringMonths, {9, 10});
    expect(species.careNotes, 'Seiva irritante');
  });

  test('species from a backup without a care sheet import with it empty',
      () async {
    final backup = {
      'format': DataExportService.formatName,
      'version': DataExportService.formatVersion,
      'exportedAt': t1.toIso8601String(),
      'entities': {
        'species': [
          {
            'id': 'species1',
            'scientificName': 'Ficus lyrata',
            'popularName': 'Figueira',
            'defaultIrrigationFrequencyDays': null,
            'recommendedSoilIds': ['loamy'],
            'createdAt': t0.toIso8601String(),
            'updatedAt': t0.toIso8601String(),
            'deletedAt': null,
          }
        ],
      },
    };

    await DataImportService(target, FakePhotoStorage())
        .importFromBytes(Uint8List.fromList(utf8.encode(jsonEncode(backup))));

    final species = await target.speciesDao.getById('species1');
    expect(species!.scientificName, 'Ficus lyrata');
    expect(species.light, isNull);
    expect(species.humidity, isNull);
    expect(species.petToxicity, PetToxicity.unknown);
    expect(species.floweringMonths, isEmpty);
    expect(species.careNotes, isNull);
  });

  test('plants from a backup without status are imported as active',
      () async {
    final backup = {
      'format': DataExportService.formatName,
      'version': DataExportService.formatVersion,
      'exportedAt': t1.toIso8601String(),
      'entities': {
        'plants': [
          {
            'id': 'plant1',
            'speciesId': 'species1',
            'nickname': 'Antiga',
            'soilId': 'loamy',
            'irrigationFrequencyDays': null,
            'acquisitionDate': t0.toIso8601String(),
            'location': null,
            'locationId': null,
            'lastIrrigatedAt': null,
            'lastPesticideAppliedAt': null,
            'pesticideReapplicationDays': null,
            'createdAt': t0.toIso8601String(),
            'updatedAt': t0.toIso8601String(),
            'deletedAt': null,
          }
        ],
      },
    };

    await DataImportService(target, FakePhotoStorage())
        .importFromBytes(Uint8List.fromList(utf8.encode(jsonEncode(backup))));

    final plant = await target.plantsDao.getById('plant1');
    expect(plant!.status, PlantStatus.active);
    expect(plant.statusChangedAt, isNull);
  });

  test('legacy location text in a backup is linked to a location',
      () async {
    Map<String, dynamic> plant(String id, String? location) => {
          'id': id,
          'speciesId': 'species1',
          'nickname': 'Antiga',
          'soilId': 'loamy',
          'acquisitionDate': t0.toIso8601String(),
          'location': location,
          'locationId': null,
          'createdAt': t0.toIso8601String(),
          'updatedAt': t0.toIso8601String(),
          'deletedAt': null,
        };
    final backup = {
      'format': DataExportService.formatName,
      'version': DataExportService.formatVersion,
      'exportedAt': t1.toIso8601String(),
      'entities': {
        'locations': [
          {
            'id': 'loc1',
            'name': 'Varanda',
            'createdAt': t0.toIso8601String(),
            'updatedAt': t0.toIso8601String(),
            'deletedAt': null,
          }
        ],
        'plants': [
          plant('plant1', 'VARANDA'),
          plant('plant2', 'Sala'),
          plant('plant3', 'sala'),
          plant('plant4', ''),
        ],
      },
    };

    await DataImportService(target, FakePhotoStorage())
        .importFromBytes(Uint8List.fromList(utf8.encode(jsonEncode(backup))));

    expect((await target.plantsDao.getById('plant1'))!.locationId, 'loc1');
    final plant2 = await target.plantsDao.getById('plant2');
    expect(plant2!.locationId, isNotNull);
    expect((await target.plantsDao.getById('plant3'))!.locationId,
        plant2.locationId);
    expect((await target.plantsDao.getById('plant4'))!.locationId, isNull);
    expect((await target.locationsDao.getAll()).map((l) => l.name),
        ['Sala', 'Varanda']);

    final archive = ZipDecoder()
        .decodeBytes(await DataExportService(target).buildArchiveBytes());
    final exported = jsonDecode(utf8.decode(archive
        .findFile(DataExportService.dataFileName)!
        .content as List<int>)) as Map<String, dynamic>;
    final plants = (exported['entities'] as Map<String, dynamic>)['plants']
        as List<dynamic>;
    expect((plants.first as Map<String, dynamic>).containsKey('location'),
        isFalse);
  });

  test('reminders survive the round trip', () async {
    await seedSpecies(source, 'Ficus lyrata', t0);
    await source.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Minha planta',
      soilType: 'loamy',
      acquisitionDate: t0,
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(2),
    ));
    await source.remindersDao.upsert(RemindersTableCompanion.insert(
      id: 'rem1',
      plantId: 'plant1',
      entryType: EntryType.fertilizer,
      intervalDays: 30,
      enabled: const Value(false),
      createdAt: t0,
      updatedAt: t1,
      localRev: const Value(3),
    ));

    final bytes = await DataExportService(source).buildArchiveBytes();
    await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final reminder = await target.remindersDao.getById('rem1');
    expect(reminder, isNotNull);
    expect(reminder!.plantId, 'plant1');
    expect(reminder.entryType, EntryType.fertilizer);
    expect(reminder.intervalDays, 30);
    expect(reminder.enabled, isFalse);
    expect(reminder.updatedAt, t1);
    expect(reminder.localRev, greaterThan(0));
  });

  test('a backup without reminders imports fine', () async {
    await seedSpecies(source, 'Ficus lyrata', t0);
    final bytes = await DataExportService(source).buildArchiveBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final data = jsonDecode(utf8.decode(archive
            .findFile(DataExportService.dataFileName)!
            .content as List<int>)) as Map<String, dynamic>;
    (data['entities'] as Map<String, dynamic>).remove('reminders');

    final summary = await DataImportService(target, FakePhotoStorage())
        .importFromBytes(Uint8List.fromList(utf8.encode(jsonEncode(data))));

    expect(summary.applied, greaterThanOrEqualTo(1));
    expect(await target.remindersDao.getAll(), isEmpty);
  });

  test('repotting entries survive the round trip; unknown types are skipped',
      () async {
    await seedSpecies(source, 'Ficus lyrata', t0);
    await source.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Minha planta',
      soilType: 'loamy',
      acquisitionDate: t0,
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(2),
    ));
    for (final id in ['e1', 'e2']) {
      await source.entriesDao.upsert(EntriesTableCompanion.insert(
        id: id,
        plantId: 'plant1',
        date: t1,
        type: EntryType.repotting,
        extraData: const Value('{"potMaterial":"fabric"}'),
        createdAt: t1,
        updatedAt: t1,
        localRev: const Value(3),
      ));
    }
    final bytes = await DataExportService(source).buildArchiveBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final data = jsonDecode(utf8.decode(archive
            .findFile(DataExportService.dataFileName)!
            .content as List<int>)) as Map<String, dynamic>;
    // As a newer version would write an entry type this one doesn't know.
    final entries = (data['entities'] as Map<String, dynamic>)['entries']
        as List<dynamic>;
    (entries.firstWhere((e) => e['id'] == 'e2') as Map)['type'] = 'grafting';

    final summary = await DataImportService(target, FakePhotoStorage())
        .importFromBytes(Uint8List.fromList(utf8.encode(jsonEncode(data))));

    expect(summary.skipped, greaterThanOrEqualTo(1));
    final entry = await target.entriesDao.getById('e1');
    expect(entry!.type, EntryType.repotting);
    expect(entry.extraData, '{"potMaterial":"fabric"}');
    expect(await target.entriesDao.getById('e2'), isNull);
  });

  test('harvest entries survive the round trip', () async {
    await seedSpecies(source, 'Solanum lycopersicum', t0);
    await source.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Tomateiro',
      soilType: 'loamy',
      acquisitionDate: t0,
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(2),
    ));
    const extra = '{"quantity":300.0,"unit":"g","duringCarencia":true}';
    await source.entriesDao.upsert(EntriesTableCompanion.insert(
      id: 'e1',
      plantId: 'plant1',
      date: t1,
      type: EntryType.harvest,
      extraData: const Value(extra),
      createdAt: t1,
      updatedAt: t1,
      localRev: const Value(3),
    ));
    final bytes = await DataExportService(source).buildArchiveBytes();

    await DataImportService(target, FakePhotoStorage()).importFromBytes(bytes);

    final entry = await target.entriesDao.getById('e1');
    expect(entry!.type, EntryType.harvest);
    expect(entry.extraData, extra);
  });

  test('rejects files that are not a Polypodium backup', () async {
    final service = DataImportService(target, FakePhotoStorage());
    await expectLater(
      service.importFromBytes(Uint8List.fromList('not a backup'.codeUnits)),
      throwsA(isA<InvalidBackupException>()),
    );
  });

  group('deviceId', () {
    const low = '1b4e28ba-2fa1-41d2-883f-0016d3cca427';
    const high = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

    Future<void> seedTie(AppDatabase db, String name, String? deviceId) =>
        db.speciesDao.upsert(SpeciesTableCompanion.insert(
          id: 'species1',
          scientificName: name,
          popularName: 'Popular',
          recommendedSoilTypes: const [],
          createdAt: t0,
          updatedAt: t1,
          localRev: const Value(1),
          deviceId: Value(deviceId),
        ));

    Future<Map<String, dynamic>> exportedSpecies(AppDatabase db) async {
      final archive = ZipDecoder()
          .decodeBytes(await DataExportService(db).buildArchiveBytes());
      final data = jsonDecode(utf8.decode(archive
          .findFile(DataExportService.dataFileName)!
          .content as List<int>)) as Map<String, dynamic>;
      return ((data['entities'] as Map<String, dynamic>)['species']
              as List<dynamic>)
          .single as Map<String, dynamic>;
    }

    test('is exported and decides exact-timestamp ties on import', () async {
      await seedTie(source, 'Do backup', high);
      expect((await exportedSpecies(source))['deviceId'], high);
      final bytes = await DataExportService(source).buildArchiveBytes();

      final importer = AppDatabase.forTesting(NativeDatabase.memory(),
          deviceId: 'importing-device');
      addTearDown(importer.close);
      await seedTie(importer, 'Local', low);
      await DataImportService(importer, FakePhotoStorage())
          .importFromBytes(bytes);

      final species = await importer.speciesDao.getById('species1');
      expect(species!.scientificName, 'Do backup');
      // Applied as a fresh local write, pushed as this device.
      expect(species.deviceId, 'importing-device');
      expect((await exportedSpecies(importer))['deviceId'],
          'importing-device');
    });

    test('a tie against a greater local deviceId keeps the local row',
        () async {
      await seedTie(source, 'Do backup', low);
      final bytes = await DataExportService(source).buildArchiveBytes();

      await seedTie(target, 'Local', high);
      await DataImportService(target, FakePhotoStorage())
          .importFromBytes(bytes);

      expect((await target.speciesDao.getById('species1'))!.scientificName,
          'Local');
    });

    test('rows from a backup without deviceId lose ties', () async {
      await seedTie(source, 'Do backup', high);
      final archive = ZipDecoder()
          .decodeBytes(await DataExportService(source).buildArchiveBytes());
      final data = jsonDecode(utf8.decode(archive
          .findFile(DataExportService.dataFileName)!
          .content as List<int>)) as Map<String, dynamic>;
      for (final rows in (data['entities'] as Map<String, dynamic>).values) {
        for (final row in rows as List<dynamic>) {
          (row as Map<String, dynamic>).remove('deviceId');
        }
      }

      await seedTie(target, 'Local', low);
      await DataImportService(target, FakePhotoStorage())
          .importFromBytes(Uint8List.fromList(utf8.encode(jsonEncode(data))));

      expect((await target.speciesDao.getById('species1'))!.scientificName,
          'Local');
    });
  });
}
