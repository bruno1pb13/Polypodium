import 'package:drift/drift.dart';

import 'app_database.dart';

part 'sync_meta_dao.g.dart';

@DriftAccessor(tables: [SyncMetaTable])
class SyncMetaDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetaDaoMixin {
  SyncMetaDao(super.db);

  /// Hands out the next monotonic revision. Must be called from within the
  /// same `db.transaction()` as the entity write it stamps -- see
  /// repository save()/delete() methods -- so the read-increment-write
  /// sequence can't interleave with a concurrent writer and hand out a
  /// duplicate revision.
  Future<int> nextRev() async {
    final row =
        await (select(syncMetaTable)..where((t) => t.id.equals(0)))
            .getSingleOrNull();
    final next = row?.nextLocalRev ?? 1;
    await into(syncMetaTable).insertOnConflictUpdate(
      SyncMetaTableCompanion.insert(
          id: const Value(0), nextLocalRev: Value(next + 1)),
    );
    return next;
  }
}
