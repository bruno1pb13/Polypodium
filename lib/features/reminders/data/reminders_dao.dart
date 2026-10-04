import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'reminders_dao.g.dart';

typedef ReminderRow = ({RemindersTableData reminder, DateTime? lastDoneAt});

@DriftAccessor(tables: [RemindersTable, EntriesTable])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  /// Active reminders joined with the date of the plant's most recent
  /// non-deleted entry of the reminder's type. Reading both tables makes the
  /// watched variant re-emit when an entry is created or deleted.
  Selectable<ReminderRow> _withLastDone({String? plantId}) {
    final lastDone = subqueryExpression<DateTime>(selectOnly(entriesTable)
      ..addColumns([entriesTable.date.max()])
      ..where(entriesTable.plantId.equalsExp(remindersTable.plantId) &
          entriesTable.type.equalsExp(remindersTable.entryType) &
          entriesTable.deletedAt.isNull()));
    final query = select(remindersTable).addColumns([lastDone])
      ..where(remindersTable.deletedAt.isNull() &
          (plantId == null
              ? const Constant(true)
              : remindersTable.plantId.equals(plantId)))
      ..orderBy([OrderingTerm.asc(remindersTable.createdAt)]);
    return query.map((row) => (
          reminder: row.readTable(remindersTable),
          lastDoneAt: row.read(lastDone),
        ));
  }

  Future<List<ReminderRow>> getAllWithLastDone() => _withLastDone().get();

  Stream<List<ReminderRow>> watchByPlantWithLastDone(String plantId) =>
      _withLastDone(plantId: plantId).watch();

  Future<List<RemindersTableData>> getAll() =>
      (select(remindersTable)..where((t) => t.deletedAt.isNull())).get();

  /// Unfiltered by [deletedAt] -- used by sync/backup merge logic.
  Future<RemindersTableData?> getById(String id) =>
      (select(remindersTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(RemindersTableCompanion companion) =>
      into(remindersTable).insertOnConflictUpdate(companion);

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(remindersTable)..where((t) => t.id.equals(id))).write(
        RemindersTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
        ),
      );

  /// Soft-deletes every active reminder of [plantId] (replicating the
  /// `KeyAction.cascade` FK behavior that only fires on a real SQLite
  /// DELETE).
  Future<void> softDeleteByPlant(String plantId,
          {required DateTime deletedAt, required int rev}) =>
      (update(remindersTable)
            ..where((t) => t.plantId.equals(plantId) & t.deletedAt.isNull()))
          .write(RemindersTableCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
        localRev: Value(rev),
      ));

  Future<List<RemindersTableData>> changesSince(int since,
          {required int limit}) =>
      (select(remindersTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
