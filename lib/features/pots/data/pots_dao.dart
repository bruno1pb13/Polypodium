import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'pots_dao.g.dart';

@DriftAccessor(tables: [PotsTable])
class PotsDao extends DatabaseAccessor<AppDatabase> with _$PotsDaoMixin {
  PotsDao(super.db);

  Future<List<PotsTableData>> getAll() => (select(potsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Stream<List<PotsTableData>> watchAll() => (select(potsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<PotsTableData?> getById(String id) =>
      (select(potsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(PotsTableCompanion companion) =>
      into(potsTable).insertOnConflictUpdate(companion);

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(potsTable)..where((t) => t.id.equals(id))).write(
        PotsTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
          deviceId: Value(attachedDatabase.deviceId),
        ),
      );

  Future<List<PotsTableData>> changesSince(int since, {required int limit}) =>
      (select(potsTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
