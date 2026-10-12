import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';

part 'entries_dao.g.dart';

/// An entry with its photos after the first, in order.
typedef EntryWithPhotos = (EntriesTableData, List<EntryPhotosTableData>);

@DriftAccessor(tables: [EntriesTable, EntryPhotosTable])
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

  /// Active entries of every plant dated on or after [since], newest first.
  Stream<List<EntriesTableData>> watchSince(DateTime since) =>
      (select(entriesTable)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(since) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  /// Plant and date of every active entry dated on or after [since]: just
  /// what a per-day count needs, without loading whole rows.
  Stream<List<(String, DateTime)>> watchDatesSince(DateTime since) {
    final query = selectOnly(entriesTable)
      ..addColumns([entriesTable.plantId, entriesTable.date])
      ..where(entriesTable.date.isBiggerOrEqualValue(since) &
          entriesTable.deletedAt.isNull());
    return query.watch().map((rows) => [
          for (final row in rows)
            (
              row.read(entriesTable.plantId)!,
              row.read(entriesTable.date)!,
            ),
        ]);
  }

  /// Active entries of every plant whose type is one of [types], newest
  /// first.
  Stream<List<EntriesTableData>> watchOfTypes(Iterable<EntryType> types) =>
      (select(entriesTable)
            ..where((t) =>
                t.type.isInValues(types) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  /// Active entries of [plantId], newest first, with their active photos.
  Future<List<EntryWithPhotos>> getByPlantWithPhotos(String plantId) =>
      _byPlantWithPhotos(plantId).get().then(_groupPhotos);

  Stream<List<EntryWithPhotos>> watchByPlantWithPhotos(String plantId) =>
      _byPlantWithPhotos(plantId).watch().map(_groupPhotos);

  JoinedSelectStatement<HasResultSet, dynamic> _byPlantWithPhotos(
          String plantId) =>
      select(entriesTable).join([
        leftOuterJoin(
            entryPhotosTable,
            entryPhotosTable.entryId.equalsExp(entriesTable.id) &
                entryPhotosTable.deletedAt.isNull()),
      ])
        ..where(entriesTable.plantId.equals(plantId) &
            entriesTable.deletedAt.isNull())
        ..orderBy([
          OrderingTerm.desc(entriesTable.date),
          OrderingTerm.asc(entriesTable.id),
          OrderingTerm.asc(entryPhotosTable.position),
        ]);

  List<EntryWithPhotos> _groupPhotos(List<TypedResult> rows) {
    final grouped = <String, EntryWithPhotos>{};
    for (final row in rows) {
      final entry = row.readTable(entriesTable);
      final photos =
          (grouped[entry.id] ??= (entry, <EntryPhotosTableData>[])).$2;
      final photo = row.readTableOrNull(entryPhotosTable);
      if (photo != null) photos.add(photo);
    }
    return grouped.values.toList();
  }

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

  /// Most recent (non-deleted) entry of [type] for [plantId], or null.
  Future<EntriesTableData?> getLastEntryOfType(
      String plantId, EntryType type) async {
    final query = select(entriesTable)
      ..where((t) =>
          t.plantId.equals(plantId) &
          t.type.equalsValue(type) &
          t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(1);
    return query.getSingleOrNull();
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
          deviceId: Value(attachedDatabase.deviceId),
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
      deviceId: Value(attachedDatabase.deviceId),
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

  /// Files of every active photo, the entries' own and their extra ones.
  Future<List<String>> getAllPhotoPaths() async {
    final rows = await (select(entriesTable)
          ..where((t) => t.photoPath.isNotNull() & t.deletedAt.isNull()))
        .get();
    final extra = await attachedDatabase.entryPhotosDao.getAll();
    return [
      ...rows.map((r) => r.photoPath!),
      ...extra.map((r) => r.photoPath),
    ];
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

  /// Path of the plant's cover photo: the one picked in
  /// `plants.cover_photo_id` (an entry photo or an entry's own photo) while
  /// it still exists among the plant's live entries, else the latest photo.
  Stream<String?> watchCoverPhotoPath(String plantId) => customSelect(
        'SELECT COALESCE('
        '(SELECT ep.photo_path FROM entry_photos ep '
        'JOIN entries e ON e.id = ep.entry_id '
        'WHERE ep.id = (SELECT cover_photo_id FROM plants WHERE id = ?1) '
        'AND e.plant_id = ?1 AND ep.deleted_at IS NULL '
        'AND e.deleted_at IS NULL), '
        '(SELECT e.photo_path FROM entries e '
        'WHERE e.id = (SELECT cover_photo_id FROM plants WHERE id = ?1) '
        'AND e.plant_id = ?1 AND e.photo_path IS NOT NULL '
        'AND e.deleted_at IS NULL), '
        '(SELECT photo_path FROM entries '
        'WHERE plant_id = ?1 AND photo_path IS NOT NULL '
        'AND deleted_at IS NULL ORDER BY date DESC LIMIT 1)'
        ') AS path',
        variables: [Variable.withString(plantId)],
        readsFrom: {
          entriesTable,
          entryPhotosTable,
          attachedDatabase.plantsTable,
        },
      ).watchSingle().map((row) => row.read<String?>('path'));

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
