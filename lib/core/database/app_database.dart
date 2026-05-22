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
import 'package:uuid/uuid.dart';

export '../../features/entries/data/entries_table.dart';
export '../../features/locations/data/locations_table.dart';
export '../../features/plants/data/plants_table.dart';
export '../../features/species/data/species_table.dart';
export 'sync_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [SpeciesTable, PlantsTable, EntriesTable, SyncQueueTable, LocationsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override


  int get schemaVersion => 2;

  late final SpeciesDao speciesDao = SpeciesDao(this);
  late final PlantsDao plantsDao = PlantsDao(this);
  late final EntriesDao entriesDao = EntriesDao(this);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this);
  late final LocationsDao locationsDao = LocationsDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // 1. Create locations table
            await m.createTable(locationsTable);

            // 2. Add locationId column to plants table
            await m.addColumn(plantsTable, plantsTable.locationId);

            // 3. Migrate data
            await transaction(() async {
              // Get all plants with a location string
              final plantsWithLocation = await (select(plantsTable)
                    ..where((t) => t.location.isNotNull()))
                  .get();

              if (plantsWithLocation.isNotEmpty) {
                // Extract unique location names
                final uniqueNames = plantsWithLocation
                    .map((p) => p.location!)
                    .where((name) => name.trim().isNotEmpty)
                    .toSet();

                final nameToId = <String, String>{};

                // Create predefined locations for each unique name
                for (final name in uniqueNames) {
                  final id = const Uuid().v4();
                  nameToId[name] = id;
                  await into(locationsTable).insert(LocationsTableCompanion.insert(
                    id: id,
                    name: name,
                    createdAt: DateTime.now(),
                  ));
                }

                // Update plants with the new locationId
                for (final plant in plantsWithLocation) {
                  final name = plant.location;
                  if (name != null && nameToId.containsKey(name)) {
                    await (update(plantsTable)..where((t) => t.id.equals(plant.id)))
                        .write(PlantsTableCompanion(
                      locationId: Value(nameToId[name]),
                    ));
                  }
                }
              }
            });
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'plantlog.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
