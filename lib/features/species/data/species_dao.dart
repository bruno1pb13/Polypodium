import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'species_dao.g.dart';

@DriftAccessor(tables: [SpeciesTable])
class SpeciesDao extends DatabaseAccessor<AppDatabase> with _$SpeciesDaoMixin {
  SpeciesDao(super.db);

  Future<List<SpeciesTableData>> getAll() => (select(speciesTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.popularName)]))
      .get();

  Stream<List<SpeciesTableData>> watchAll() => (select(speciesTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.popularName)]))
      .watch();

  Future<SpeciesTableData?> getById(String id) =>
      (select(speciesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(SpeciesTableCompanion companion) =>
      into(speciesTable).insertOnConflictUpdate(companion);

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(speciesTable)..where((t) => t.id.equals(id))).write(
        SpeciesTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
        ),
      );

  /// All rows (including tombstones) with localRev > [since], for sync
  /// outbound only -- unlike [getAll]/[watchAll], must not filter deleted
  /// rows since tombstones need to propagate to peers.
  Future<List<SpeciesTableData>> changesSince(int since,
          {required int limit}) =>
      (select(speciesTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
