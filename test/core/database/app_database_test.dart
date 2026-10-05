import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('SpeciesTable allows null defaultIrrigationFrequencyDays', () async {
    final id = 'test-species';
    await db.into(db.speciesTable).insert(
          SpeciesTableCompanion.insert(
            id: id,
            scientificName: 'Test scientific',
            popularName: 'Test popular',
            defaultIrrigationFrequencyDays: const Value(null),
            recommendedSoilTypes: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    final species = await (db.select(db.speciesTable)..where((t) => t.id.equals(id))).getSingle();
    expect(species.defaultIrrigationFrequencyDays, isNull);
  });

  test('migration from before v10 resets to the current schema', () async {
    await db.close();
    // A v9 database from the event-log sync era.
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE plants (
          id TEXT NOT NULL PRIMARY KEY,
          species_id TEXT NOT NULL,
          nickname TEXT NOT NULL,
          soil_type TEXT NOT NULL,
          acquisition_date INTEGER NOT NULL,
          location TEXT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending'
        )
      ''');
      raw.execute('''
        CREATE TABLE sync_queue (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          payload TEXT NOT NULL
        )
      ''');
      raw.execute('''
        INSERT INTO plants (id, species_id, nickname, soil_type,
          acquisition_date)
        VALUES ('p1', 's1', 'Old plant', 'loamy', 0)
      ''');
      raw.execute('PRAGMA user_version = 9');
    }));

    expect(await db.plantsDao.getById('p1'), isNull);
    expect(await db.soilsDao.getAllSoils(), isNotEmpty);

    final columns =
        await db.customSelect('PRAGMA table_info(plants)').get();
    final names = columns.map((c) => c.read<String>('name'));
    expect(names, containsAll(['status', 'last_pesticide_applied_at']));
    expect(names, isNot(contains('location')));

    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final tableNames = tables.map((t) => t.read<String>('name'));
    expect(tableNames, containsAll(['reminders', 'defensivos', 'sync_cursors']));
    expect(tableNames, isNot(contains('sync_queue')));

    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);
  });

  test('migration from v11 adds plant status columns defaulting to active',
      () async {
    await db.close();
    // A v11 database: plants without status/statusChangedAt. Only the table
    // touched by the v11 -> v12 step is needed.
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE plants (
          id TEXT NOT NULL PRIMARY KEY,
          species_id TEXT NOT NULL,
          nickname TEXT NOT NULL,
          soil_type TEXT NOT NULL,
          irrigation_frequency_days INTEGER NULL,
          acquisition_date INTEGER NOT NULL,
          location TEXT NULL,
          location_id TEXT NULL,
          last_irrigated_at INTEGER NULL,
          last_pesticide_applied_at INTEGER NULL,
          pesticide_reapplication_days INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER NULL,
          local_rev INTEGER NOT NULL DEFAULT 0
        )
      ''');
      raw.execute('''
        INSERT INTO plants (id, species_id, nickname, soil_type,
          acquisition_date, created_at, updated_at)
        VALUES ('p1', 's1', 'Old plant', 'loamy', 0, 0, 0)
      ''');
      raw.execute('PRAGMA user_version = 11');
    }));

    final plant = await db.plantsDao.getById('p1');
    expect(plant, isNotNull);
    expect(plant!.status, PlantStatus.active);
    expect(plant.statusChangedAt, isNull);

    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);
  });

  test('migration from v12 creates the reminders table', () async {
    await db.close();
    // A v12 database: plants already carry status, no reminders table yet.
    // Only the table the new reminders reference is needed.
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE plants (
          id TEXT NOT NULL PRIMARY KEY,
          species_id TEXT NOT NULL,
          nickname TEXT NOT NULL,
          soil_type TEXT NOT NULL,
          irrigation_frequency_days INTEGER NULL,
          acquisition_date INTEGER NOT NULL,
          location TEXT NULL,
          location_id TEXT NULL,
          last_irrigated_at INTEGER NULL,
          last_pesticide_applied_at INTEGER NULL,
          pesticide_reapplication_days INTEGER NULL,
          status TEXT NOT NULL DEFAULT 'active',
          status_changed_at INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER NULL,
          local_rev INTEGER NOT NULL DEFAULT 0
        )
      ''');
      raw.execute('PRAGMA user_version = 12');
    }));

    await db.remindersDao.upsert(RemindersTableCompanion.insert(
      id: 'r1',
      plantId: 'p1',
      entryType: EntryType.fertilizer,
      intervalDays: 30,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ));

    final reminder = await db.remindersDao.getById('r1');
    expect(reminder?.entryType, EntryType.fertilizer);
    expect(reminder?.enabled, isTrue);

    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);
  });

  test('migration from v13 links legacy location text and drops the column',
      () async {
    await db.close();
    // A v13 database: plants still carry the free-text location column.
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE locations (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NULL,
          latitude REAL NULL,
          longitude REAL NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER NULL,
          local_rev INTEGER NOT NULL DEFAULT 0
        )
      ''');
      raw.execute('''
        CREATE TABLE plants (
          id TEXT NOT NULL PRIMARY KEY,
          species_id TEXT NOT NULL,
          nickname TEXT NOT NULL,
          soil_type TEXT NOT NULL,
          irrigation_frequency_days INTEGER NULL,
          acquisition_date INTEGER NOT NULL,
          location TEXT NULL,
          location_id TEXT NULL,
          last_irrigated_at INTEGER NULL,
          last_pesticide_applied_at INTEGER NULL,
          pesticide_reapplication_days INTEGER NULL,
          status TEXT NOT NULL DEFAULT 'active',
          status_changed_at INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER NULL,
          local_rev INTEGER NOT NULL DEFAULT 0
        )
      ''');
      raw.execute('''
        CREATE TABLE sync_meta (
          id INTEGER NOT NULL PRIMARY KEY,
          next_local_rev INTEGER NOT NULL DEFAULT 1
        )
      ''');
      raw.execute('INSERT INTO sync_meta VALUES (0, 10)');
      raw.execute('''
        INSERT INTO locations (id, name, created_at, updated_at, local_rev)
        VALUES ('balcony', 'Varanda', 0, 0, 1)
      ''');
      raw.execute('''
        INSERT INTO plants (id, species_id, nickname, soil_type,
          acquisition_date, location, location_id, deleted_at, created_at,
          updated_at, local_rev)
        VALUES
          ('p1', 's1', 'A', 'loamy', 0, ' varanda ', NULL, NULL, 0, 0, 2),
          ('p2', 's1', 'B', 'loamy', 0, 'Sala', NULL, NULL, 0, 0, 3),
          ('p3', 's1', 'C', 'loamy', 0, 'sala', NULL, NULL, 0, 0, 4),
          ('p4', 's1', 'D', 'loamy', 0, '  ', NULL, NULL, 0, 0, 5),
          ('p5', 's1', 'E', 'loamy', 0, 'Quarto', 'balcony', NULL, 0, 0, 6),
          ('p6', 's1', 'F', 'loamy', 0, 'Cozinha', NULL, 1, 0, 0, 7)
      ''');
      raw.execute('PRAGMA user_version = 13');
    }));

    final p1 = await db.plantsDao.getById('p1');
    expect(p1!.locationId, 'balcony');
    expect(p1.localRev, greaterThanOrEqualTo(10));

    final p2 = await db.plantsDao.getById('p2');
    final p3 = await db.plantsDao.getById('p3');
    expect(p2!.locationId, isNotNull);
    expect(p3!.locationId, p2.locationId);
    expect(p3.localRev, greaterThanOrEqualTo(10));

    final living = await db.locationsDao.getById(p2.locationId!);
    expect(living!.name, 'Sala');
    expect(living.localRev, greaterThanOrEqualTo(10));

    final p4 = await db.plantsDao.getById('p4');
    expect(p4!.locationId, isNull);
    expect(p4.localRev, 5);

    final p5 = await db.plantsDao.getById('p5');
    expect(p5!.locationId, 'balcony');
    expect(p5.localRev, 6);

    expect((await db.plantsDao.getById('p6'))!.locationId, isNull);
    expect((await db.locationsDao.getAll()).map((l) => l.name),
        ['Sala', 'Varanda']);

    final columns =
        await db.customSelect('PRAGMA table_info(plants)').get();
    expect(columns.map((c) => c.read<String>('name')),
        isNot(contains('location')));
    expect(columns.map((c) => c.read<String>('name')),
        contains('location_id'));
  });

  test('migration from v14 adds a null deviceId to every synced table',
      () async {
    await db.close();
    // A v14 database: plants and locations without device_id. Only the
    // tables touched by the test are needed.
    db = AppDatabase.forTesting(
        NativeDatabase.memory(setup: (raw) {
          raw.execute('''
            CREATE TABLE locations (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT NULL,
              latitude REAL NULL,
              longitude REAL NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL,
              local_rev INTEGER NOT NULL DEFAULT 0
            )
          ''');
          raw.execute('''
            CREATE TABLE plants (
              id TEXT NOT NULL PRIMARY KEY,
              species_id TEXT NOT NULL,
              nickname TEXT NOT NULL,
              soil_type TEXT NOT NULL,
              irrigation_frequency_days INTEGER NULL,
              acquisition_date INTEGER NOT NULL,
              location_id TEXT NULL,
              last_irrigated_at INTEGER NULL,
              last_pesticide_applied_at INTEGER NULL,
              pesticide_reapplication_days INTEGER NULL,
              status TEXT NOT NULL DEFAULT 'active',
              status_changed_at INTEGER NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL,
              local_rev INTEGER NOT NULL DEFAULT 0
            )
          ''');
          raw.execute('''
            INSERT INTO plants (id, species_id, nickname, soil_type,
              acquisition_date, created_at, updated_at, local_rev)
            VALUES ('p1', 's1', 'Old plant', 'loamy', 0, 0, 0, 3)
          ''');
          raw.execute('PRAGMA user_version = 14');
        }),
        deviceId: 'device-a');

    // Existing rows keep an unknown writer.
    final plant = await db.plantsDao.getById('p1');
    expect(plant!.deviceId, isNull);
    expect(plant.localRev, 3);

    for (final table in ['plants', 'locations']) {
      final columns =
          await db.customSelect('PRAGMA table_info($table)').get();
      expect(columns.map((c) => c.read<String>('name')), contains('device_id'),
          reason: table);
    }

    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 15);
  });

  test('the v14 location fix stamps the deviceId on its writes', () async {
    await db.close();
    db = AppDatabase.forTesting(
        NativeDatabase.memory(setup: (raw) {
          raw.execute('''
            CREATE TABLE locations (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT NULL,
              latitude REAL NULL,
              longitude REAL NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL,
              local_rev INTEGER NOT NULL DEFAULT 0
            )
          ''');
          raw.execute('''
            CREATE TABLE plants (
              id TEXT NOT NULL PRIMARY KEY,
              species_id TEXT NOT NULL,
              nickname TEXT NOT NULL,
              soil_type TEXT NOT NULL,
              irrigation_frequency_days INTEGER NULL,
              acquisition_date INTEGER NOT NULL,
              location TEXT NULL,
              location_id TEXT NULL,
              last_irrigated_at INTEGER NULL,
              last_pesticide_applied_at INTEGER NULL,
              pesticide_reapplication_days INTEGER NULL,
              status TEXT NOT NULL DEFAULT 'active',
              status_changed_at INTEGER NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL,
              local_rev INTEGER NOT NULL DEFAULT 0
            )
          ''');
          raw.execute('''
            CREATE TABLE sync_meta (
              id INTEGER NOT NULL PRIMARY KEY,
              next_local_rev INTEGER NOT NULL DEFAULT 1
            )
          ''');
          raw.execute('''
            INSERT INTO plants (id, species_id, nickname, soil_type,
              acquisition_date, location, created_at, updated_at, local_rev)
            VALUES ('p1', 's1', 'A', 'loamy', 0, 'Sala', 0, 0, 2)
          ''');
          raw.execute('PRAGMA user_version = 13');
        }),
        deviceId: 'device-a');

    final plant = await db.plantsDao.getById('p1');
    expect(plant!.deviceId, 'device-a');
    final location = await db.locationsDao.getById(plant.locationId!);
    expect(location!.deviceId, 'device-a');
  });
}
