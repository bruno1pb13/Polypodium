import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'entry_photos_dao.g.dart';

@DriftAccessor(tables: [EntryPhotosTable, EntriesTable])
class EntryPhotosDao extends DatabaseAccessor<AppDatabase>
    with _$EntryPhotosDaoMixin {
  EntryPhotosDao(super.db);

  /// Unfiltered by [deletedAt], for sync apply logic.
  Future<EntryPhotosTableData?> getById(String id) =>
      (select(entryPhotosTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Active photos of [entryIds], by entry and position.
  Future<List<EntryPhotosTableData>> getByEntries(Iterable<String> entryIds) =>
      (select(entryPhotosTable)
            ..where((t) => t.entryId.isIn(entryIds) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.asc(t.entryId),
              (t) => OrderingTerm.asc(t.position),
            ]))
          .get();

  /// Active photos whose entry is still active too.
  Future<List<EntryPhotosTableData>> getAll() {
    final query = select(entryPhotosTable).join([
      innerJoin(
          entriesTable, entriesTable.id.equalsExp(entryPhotosTable.entryId)),
    ])
      ..where(entryPhotosTable.deletedAt.isNull() &
          entriesTable.deletedAt.isNull());
    return query.map((row) => row.readTable(entryPhotosTable)).get();
  }

  Future<void> upsert(EntryPhotosTableCompanion companion) =>
      into(entryPhotosTable).insertOnConflictUpdate(companion);

  /// Soft-deletes the active photos of [entryId], each as its own local write
  /// (pushed one by one, like any other row). Returns the deleted rows so the
  /// caller can remove their files.
  Future<List<EntryPhotosTableData>> softDeleteByEntry(String entryId,
      {required DateTime deletedAt}) async {
    final rows = await getByEntries([entryId]);
    for (final row in rows) {
      final rev = await attachedDatabase.syncMetaDao.nextRev();
      await (update(entryPhotosTable)..where((t) => t.id.equals(row.id)))
          .write(EntryPhotosTableCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
        localRev: Value(rev),
        deviceId: Value(attachedDatabase.deviceId),
      ));
    }
    return rows;
  }

  Future<List<EntryPhotosTableData>> changesSince(int since,
          {required int limit}) =>
      (select(entryPhotosTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
