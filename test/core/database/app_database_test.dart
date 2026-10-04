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
    expect(version.read<int>('user_version'), 13);
  });
}

