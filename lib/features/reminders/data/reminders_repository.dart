import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../domain/reminder_model.dart';
import 'reminders_dao.dart';

class RemindersRepository {
  RemindersRepository(AppDatabase db)
      : _db = db,
        _dao = db.remindersDao;

  final AppDatabase _db;
  final RemindersDao _dao;

  /// Every active reminder (enabled or not) with its derived last-done date.
  Future<List<ReminderStatus>> getAllStatuses() async =>
      (await _dao.getAllWithLastDone()).map(_statusFromRow).toList();

  Stream<List<ReminderStatus>> watchAllStatuses() => _dao
      .watchAllWithLastDone()
      .map((rows) => rows.map(_statusFromRow).toList());

  /// Re-emits on reminder changes and on entry changes (new last-done date).
  Stream<List<ReminderStatus>> watchStatusesByPlant(String plantId) => _dao
      .watchByPlantWithLastDone(plantId)
      .map((rows) => rows.map(_statusFromRow).toList());

  Future<ReminderModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _fromRow(row);
  }

  Future<void> save(ReminderModel reminder) async {
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao
          .upsert(_toCompanion(reminder, updatedAt: DateTime.now(), rev: rev));
    });
  }

  /// Makes [plantId]'s reminder for [type] repeat every [intervalDays],
  /// creating it when missing. An existing one is re-enabled, since setting
  /// an interval from a diary entry means the user wants the care tracked.
  /// Returns whether anything changed.
  Future<bool> setInterval(
      String plantId, EntryType type, int intervalDays) async {
    final row = await _dao.getActiveByPlantAndType(plantId, type);
    final existing = row == null ? null : _fromRow(row);
    if (existing != null &&
        existing.intervalDays == intervalDays &&
        existing.enabled) {
      return false;
    }
    await save(existing?.copyWith(intervalDays: intervalDays, enabled: true) ??
        ReminderModel(
          id: const Uuid().v4(),
          plantId: plantId,
          entryType: type,
          intervalDays: intervalDays,
          createdAt: DateTime.now(),
        ));
    return true;
  }

  Future<void> delete(String id) async {
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.softDelete(id, deletedAt: DateTime.now(), rev: rev);
    });
  }

  static ReminderStatus _statusFromRow(ReminderRow row) => ReminderStatus(
        reminder: _fromRow(row.reminder),
        lastDoneAt: row.lastDoneAt,
      );

  static ReminderModel _fromRow(RemindersTableData row) => ReminderModel(
        id: row.id,
        plantId: row.plantId,
        entryType: row.entryType,
        intervalDays: row.intervalDays,
        enabled: row.enabled,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        localRev: row.localRev,
      );

  RemindersTableCompanion _toCompanion(ReminderModel m,
          {required DateTime updatedAt, required int rev}) =>
      RemindersTableCompanion.insert(
        id: m.id,
        plantId: m.plantId,
        entryType: m.entryType,
        intervalDays: m.intervalDays,
        enabled: Value(m.enabled),
        createdAt: m.createdAt,
        updatedAt: updatedAt,
        localRev: Value(rev),
        deviceId: Value(_db.deviceId),
      );
}
