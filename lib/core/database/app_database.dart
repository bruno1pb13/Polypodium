import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../enums.dart';
import '../l10n/l10n.dart';
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
import 'sync_cursors_dao.dart';
import 'sync_cursors_table.dart';
import 'sync_meta_dao.dart';
import 'sync_meta_table.dart';

export '../../features/entries/data/entries_table.dart';
export '../../features/locations/data/locations_table.dart';
export '../../features/plants/data/plants_table.dart';
export '../../features/soils/data/soils_table.dart';
export '../../features/species/data/species_table.dart';
export 'sync_cursors_table.dart';
export 'sync_meta_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SpeciesTable,
    PlantsTable,
    EntriesTable,
    LocationsTable,
    SoilsTable,
    SyncMetaTable,
    SyncCursorsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({String fileName = 'polypodium.db'})
      : super(_openConnection(fileName));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  late final SpeciesDao speciesDao = SpeciesDao(this);
  late final PlantsDao plantsDao = PlantsDao(this);
  late final EntriesDao entriesDao = EntriesDao(this);
  late final LocationsDao locationsDao = LocationsDao(this);
  late final SoilsDao soilsDao = SoilsDao(this);
  late final SyncMetaDao syncMetaDao = SyncMetaDao(this);
  late final SyncCursorsDao syncCursorsDao = SyncCursorsDao(this);

  Future<void> _seedFresh() async {
    await into(syncMetaTable).insertOnConflictUpdate(
      SyncMetaTableCompanion.insert(
          id: const Value(0), nextLocalRev: const Value(1)),
    );
    final now = DateTime.now();
    // Seeded soils are persisted (and synced) as regular data, so they are
    // created once in the device language at database-creation time.
    final l10n = systemL10n();
    for (final type in SoilType.values) {
      await into(soilsTable).insertOnConflictUpdate(
        SoilsTableCompanion.insert(
          id: type.name,
          name: type.label(l10n),
          composition: Value(type.description(l10n)),
          imagePath: Value(type.imagePath),
          imageSource: Value(type.imageSource),
          createdAt: now,
          updatedAt: now,
          isSeeded: const Value(true),
        ),
      );
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedFresh();
        },
        onUpgrade: (m, from, to) async {
          if (from < 10) {
            // Pull/ack + row-versioning rewrite of sync (event-log ->
            // per-row rev/updatedAt/deletedAt). No production data exists
            // yet to preserve across this shape change, so upgrading from
            // any prior schema just resets to a fresh, empty database
            // rather than carrying forward a chain of dead syncStatus-era
            // migration steps. Drop children before parents, recreate
            // parents before children, to respect FK constraints.
            await m.deleteTable('entries');
            await m.deleteTable('plants');
            await m.deleteTable('species');
            await m.deleteTable('soils');
            await m.deleteTable('locations');
            await m.deleteTable('sync_queue');
            await m.deleteTable('sync_meta');
            await m.deleteTable('sync_cursors');

            await m.createTable(speciesTable);
            await m.createTable(soilsTable);
            await m.createTable(locationsTable);
            await m.createTable(plantsTable);
            await m.createTable(entriesTable);
            await m.createTable(syncMetaTable);
            await m.createTable(syncCursorsTable);

            await _seedFresh();
          }
        },
      );

  static LazyDatabase _openConnection(String fileName) {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, fileName));
      return NativeDatabase.createInBackground(file);
    });
  }
}
