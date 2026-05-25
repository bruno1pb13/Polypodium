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
import 'converters.dart';
import 'sync_queue_dao.dart';
import 'sync_queue_table.dart';

export '../../features/entries/data/entries_table.dart';
export '../../features/locations/data/locations_table.dart';
export '../../features/plants/data/plants_table.dart';
export '../../features/species/data/species_table.dart';
export 'sync_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SpeciesTable,
    PlantsTable,
    EntriesTable,
    SyncQueueTable,
    LocationsTable
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  late final SpeciesDao speciesDao = SpeciesDao(this);
  late final PlantsDao plantsDao = PlantsDao(this);
  late final EntriesDao entriesDao = EntriesDao(this);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this);
  late final LocationsDao locationsDao = LocationsDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
