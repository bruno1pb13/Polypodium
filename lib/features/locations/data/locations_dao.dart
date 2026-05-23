import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'locations_dao.g.dart';

@DriftAccessor(tables: [LocationsTable])
class LocationsDao extends DatabaseAccessor<AppDatabase>
    with _$LocationsDaoMixin {
  LocationsDao(super.db);

  Future<List<LocationsTableData>> getAll() =>
      (select(locationsTable)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Stream<List<LocationsTableData>> watchAll() =>
      (select(locationsTable)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<LocationsTableData?> getById(String id) =>
      (select(locationsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(LocationsTableCompanion companion) =>
      into(locationsTable).insertOnConflictUpdate(companion);

  Future<int> deleteById(String id) =>
      (delete(locationsTable)..where((t) => t.id.equals(id))).go();
}
