import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';

part 'entries_dao.g.dart';

@DriftAccessor(tables: [EntriesTable])
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
  EntriesDao(super.db);

  Future<List<EntriesTableData>> getAll() =>
      (select(entriesTable)..where((t) => t.deletedAt.isNull())).get();

  Future<List<EntriesTableData>> getByPlant(String plantId) =>
      (select(entriesTable)
            ..where((t) => t.plantId.equals(plantId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<EntriesTableData>> watchByPlant(String plantId) =>
      (select(entriesTable)
            ..where((t) => t.plantId.equals(plantId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  /// Unfiltered by [deletedAt] -- used by sync apply logic and by
  /// [EntriesRepository.delete] to inspect an entry (including an
  /// already-tombstoned one) regardless of its visibility to the UI.
  Future<EntriesTableData?> getById(String id) =>
      (select(entriesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<DateTime?> getLastIrrigationDate(String plantId) async {
    final query = select(entriesTable)
      ..where((t) =>
          t.plantId.equals(plantId) &
          t.type.equalsValue(EntryType.irrigation) &
          t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.date;
  }

  Future<void> insert(EntriesTableCompanion companion) =>
      into(entriesTable).insert(companion);

  Future<void> upsert(EntriesTableCompanion companion) =>
      into(entriesTable).insertOnConflictUpdate(companion);

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(entriesTable)..where((t) => t.id.equals(id))).write(
        EntriesTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
        ),
      );

  /// Soft-deletes every active entry for [plantId] (replicating the
  /// `KeyAction.cascade` FK behavior that only fires on a real SQLite
  /// DELETE). Returns the deleted rows so the caller can clean up their
  /// photo files.
  Future<List<EntriesTableData>> softDeleteByPlant(String plantId,
      {required DateTime deletedAt, required int rev}) async {
    final rows = await (select(entriesTable)
          ..where((t) => t.plantId.equals(plantId) & t.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) return const [];
    await (update(entriesTable)..where((t) => t.plantId.equals(plantId)))
        .write(EntriesTableCompanion(
      deletedAt: Value(deletedAt),
      updatedAt: Value(deletedAt),
      localRev: Value(rev),
    ));
    return rows;
  }

  Future<List<EntriesTableData>> changesSince(int since,
          {required int limit}) =>
      (select(entriesTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();

  Future<List<String>> getPhotoPathsForPlant(String plantId) async {
    final rows = await (select(entriesTable)
          ..where((t) =>
              t.plantId.equals(plantId) &
              t.photoPath.isNotNull() &
              t.deletedAt.isNull()))
        .get();
    return rows.map((r) => r.photoPath!).toList();
  }

  Future<List<String>> getAllPhotoPaths() async {
    final rows = await (select(entriesTable)
          ..where((t) => t.photoPath.isNotNull() & t.deletedAt.isNull()))
        .get();
    return rows.map((r) => r.photoPath!).toList();
  }

  Future<String?> getLatestPhotoPath(String plantId) async {
    final row = await (select(entriesTable)
          ..where((t) =>
              t.plantId.equals(plantId) &
              t.photoPath.isNotNull() &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
    return row?.photoPath;
  }

  Stream<String?> watchLatestPhotoPath(String plantId) {
    return (select(entriesTable)
          ..where((t) =>
              t.plantId.equals(plantId) &
              t.photoPath.isNotNull() &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row?.photoPath);
  }

  /// Returns active entries beyond [keepCount] (oldest first) using a SQL
  /// OFFSET, evitando carregar todas as entradas da planta em memória.
  Future<List<EntriesTableData>> getOverRetentionLimit(
    String plantId, {
    int keepCount = 30,
  }) {
    return (select(entriesTable)
          ..where((t) => t.plantId.equals(plantId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(0x7fffffff, offset: keepCount))
        .get();
  }

  Future<bool> hasChangesSince(String plantId, int cursor) async {
    final row = await (select(entriesTable)
          ..where((t) =>
              t.plantId.equals(plantId) & t.localRev.isBiggerThanValue(cursor))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }
}
