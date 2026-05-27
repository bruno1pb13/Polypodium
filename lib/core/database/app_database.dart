import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../enums.dart';
import '../../features/entries/data/entries_dao.dart';
import '../../features/entries/data/entries_table.dart';
import '../../features/locations/data/locations_dao.dart';
import '../../features/locations/data/locations_table.dart';
import '../../features/plants/data/plants_dao.dart';
import '../../features/plants/data/plants_table.dart';
import '../../features/species/data/species_dao.dart';
import '../../features/species/data/species_table.dart';
import '../../features/soils/data/soils_dao.dart';
import '../../features/soils/data/soils_table.dart';
import 'converters.dart';
import 'sync_queue_dao.dart';
import 'sync_queue_table.dart';

export '../../features/entries/data/entries_table.dart';
export '../../features/locations/data/locations_table.dart';
export '../../features/plants/data/plants_table.dart';
export '../../features/soils/data/soils_table.dart';
export '../../features/species/data/species_table.dart';
export 'sync_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SpeciesTable,
    PlantsTable,
    EntriesTable,
    SyncQueueTable,
    LocationsTable,
    SoilsTable
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  late final SpeciesDao speciesDao = SpeciesDao(this);
  late final PlantsDao plantsDao = PlantsDao(this);
  late final EntriesDao entriesDao = EntriesDao(this);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this);
  late final LocationsDao locationsDao = LocationsDao(this);
  late final SoilsDao soilsDao = SoilsDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed all soils on creation
          for (final type in SoilType.values) {
            await into(soilsTable).insert(
              SoilsTableCompanion.insert(
                id: type.name,
                name: type.label,
                composition: Value(type.description),
                imagePath: Value(type.imagePath),
                imageSource: Value(type.imageSource),
                createdAt: DateTime.now(),
                syncStatus: const Value(SyncStatus.synced),
              ),
            );
          }
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // ... (existing code for v1 to v2)
          }
          if (from < 3) {
            // Migration for version 3: making defaultIrrigationFrequencyDays nullable
            // ignore: experimental_member_use
            await m.alterTable(TableMigration(
              speciesTable,
            ));
          }
          if (from < 4) {
            // 1. Create soils table
            await m.createTable(soilsTable);

            // 2. Seed soils with defaults from SoilType enum
            for (final type in SoilType.values) {
              await into(soilsTable).insert(
                SoilsTableCompanion.insert(
                  id: type.name, // Use name as ID for migration
                  name: type.label,
                  createdAt: DateTime.now(),
                  syncStatus: const Value(SyncStatus.synced),
                ),
              );
            }

            // 3. Update plants table to use text ID instead of enum-mapped string
            // Actually, plantsTable.soilType is already TextColumn, but mapped with SoilTypeConverter.
            // We need to change the mapping or just store the ID.
            // Since we're changing the model too, we'll keep the column name but change what it stores.
            // Drift handles table updates via alterTable but for column type/converter changes it's trickier.
            // For now, we'll just migrate the values.
            
            // 4. Species recommended soils: currently JSON list of enum names.
            // Since we used enum names as IDs for the seed, the content is already compatible!
          }
          if (from < 5) {
            await m.addColumn(locationsTable, locationsTable.latitude);
            await m.addColumn(locationsTable, locationsTable.longitude);
          }
          if (from < 6) {
            // Seed new soils introduced in SoilType enum
            // We use insertOrReplace to update existing ones with descriptions too
            for (final type in SoilType.values) {
              await into(soilsTable).insert(
                SoilsTableCompanion.insert(
                  id: type.name,
                  name: type.label,
                  composition: Value(type.description),
                  createdAt: DateTime.now(),
                  syncStatus: const Value(SyncStatus.synced),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
          if (from < 7) {
            await m.addColumn(soilsTable, soilsTable.imagePath);
            await m.addColumn(soilsTable, soilsTable.imageSource);
          }
          if (from < 8) {
            // Re-seed soils with image paths and sources populated from
            // the current SoilType enum. Only touches seeded rows (whose
            // id matches an enum name); user-created soils are untouched.
            for (final type in SoilType.values) {
              await into(soilsTable).insert(
                SoilsTableCompanion.insert(
                  id: type.name,
                  name: type.label,
                  composition: Value(type.description),
                  imagePath: Value(type.imagePath),
                  imageSource: Value(type.imageSource),
                  createdAt: DateTime.now(),
                  syncStatus: const Value(SyncStatus.synced),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'polypodium.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
