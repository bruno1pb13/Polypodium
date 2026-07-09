import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../../../core/storage/photo_storage.dart';
import '../domain/entry_model.dart';
import 'entries_dao.dart';

class EntriesRepository {
  EntriesRepository(AppDatabase db, this._photoStorage)
      : _db = db,
        _dao = db.entriesDao;

  final AppDatabase _db;
  final EntriesDao _dao;
  final PhotoStorage _photoStorage;

  static const _retentionLimit = 30;

  Future<EntryModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _fromRow(row);
  }

  Future<List<EntryModel>> getByPlant(String plantId) async {
    final rows = await _dao.getByPlant(plantId);
    return rows.map(_fromRow).toList();
  }

  Stream<List<EntryModel>> watchByPlant(String plantId) =>
      _dao.watchByPlant(plantId).map((rows) => rows.map(_fromRow).toList());

  Future<void> create(EntryModel entry) async {
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao
          .insert(_toCompanion(entry, updatedAt: DateTime.now(), rev: rev));
    });
    await _enforceRetentionPolicy(entry.plantId);
  }

  Future<void> delete(String id) async {
    final entry = await getById(id);
    if (entry?.type == EntryType.history) {
      throw Exception('Registros de histórico não podem ser removidos.');
    }
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.softDelete(id, deletedAt: DateTime.now(), rev: rev);
    });
    if (entry?.photoPath != null) {
      await _photoStorage.deletePhoto(entry!.photoPath!);
    }
  }

  // ---------------------------------------------------------------------------

  /// Soft-deletes entries beyond [_retentionLimit] (oldest first) and cleans
  /// orphaned photo files from disk.
  Future<void> _enforceRetentionPolicy(String plantId) async {
    final overflow =
        await _dao.getOverRetentionLimit(plantId, keepCount: _retentionLimit);
    if (overflow.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _db.transaction(() async {
      for (final row in overflow) {
        final rev = await _db.syncMetaDao.nextRev();
        await _dao.softDelete(row.id, deletedAt: now, rev: rev);
      }
    });
    for (final row in overflow) {
      if (row.photoPath != null) {
        await _photoStorage.deletePhoto(row.photoPath!);
      }
    }

    // Remove any photos on disk that are no longer referenced by any entry
    final referenced = await _dao.getAllPhotoPaths();
    await _photoStorage.cleanOrphanPhotos(referenced);
  }

  static EntryModel _fromRow(EntriesTableData row) => EntryModel(
        id: row.id,
        plantId: row.plantId,
        date: row.date,
        photoPath: row.photoPath,
        note: row.note,
        type: row.type,
        numericValue: row.numericValue,
        extraData: row.extraData,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        localRev: row.localRev,
      );

  static EntriesTableCompanion _toCompanion(EntryModel m,
          {required DateTime updatedAt, required int rev}) =>
      EntriesTableCompanion.insert(
        id: m.id,
        plantId: m.plantId,
        date: m.date,
        photoPath: Value(m.photoPath),
        note: Value(m.note),
        type: m.type,
        numericValue: Value(m.numericValue),
        extraData: Value(m.extraData),
        createdAt: m.createdAt,
        updatedAt: updatedAt,
        localRev: Value(rev),
      );
}
