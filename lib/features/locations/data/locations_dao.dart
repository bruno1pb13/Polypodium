import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'locations_dao.g.dart';

@DriftAccessor(tables: [LocationsTable])
class LocationsDao extends DatabaseAccessor<AppDatabase>
    with _$LocationsDaoMixin {
  LocationsDao(super.db);

  Future<List<LocationsTableData>> getAll() => (select(locationsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Stream<List<LocationsTableData>> watchAll() => (select(locationsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<LocationsTableData?> getById(String id) =>
      (select(locationsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(LocationsTableCompanion companion) =>
      into(locationsTable).insertOnConflictUpdate(companion);

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(locationsTable)..where((t) => t.id.equals(id))).write(
        LocationsTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
        ),
      );

  Future<List<LocationsTableData>> changesSince(int since,
          {required int limit}) =>
      (select(locationsTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
