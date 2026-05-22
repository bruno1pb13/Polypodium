import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../../../core/storage/photo_storage.dart';
import '../domain/entry_model.dart';
import 'entries_dao.dart';

class EntriesRepository {
  EntriesRepository(AppDatabase db, this._photoStorage)
      : _dao = db.entriesDao,
        _syncQueueDao = db.syncQueueDao;

  final EntriesDao _dao;
  final _syncQueueDao;
  final PhotoStorage _photoStorage;

  static const _retentionLimit = 30;

  Future<List<EntryModel>> getByPlant(String plantId) async {
    final rows = await _dao.getByPlant(plantId);
    return rows.map(_fromRow).toList();
  }

  Stream<List<EntryModel>> watchByPlant(String plantId) =>
      _dao.watchByPlant(plantId).map((rows) => rows.map(_fromRow).toList());

  Future<void> create(EntryModel entry) async {
    await _dao.insert(_toCompanion(entry));
    // TODO(sync): Enqueue for server sync
    await _syncQueueDao.enqueue(
      entityType: 'entry',
      entityId: entry.id,
      operation: 'create',
      payload: entry.toJsonString(),
    );
    await _enforceRetentionPolicy(entry.plantId);
  }

  Future<void> delete(String id, {String? photoPath}) async {
    if (photoPath != null) await _photoStorage.deletePhoto(photoPath);
    await _dao.deleteById(id);
    // TODO(sync): Enqueue deletion for server sync
    await _syncQueueDao.enqueue(
      entityType: 'entry',
      entityId: id,
      operation: 'delete',
      payload: '{"id":"$id"}',
    );
  }

  // ---------------------------------------------------------------------------

  /// Deletes entries beyond [_retentionLimit] (oldest first) and cleans
  /// orphaned photo files from disk.
  Future<void> _enforceRetentionPolicy(String plantId) async {
    final overflow = await _dao.getOverRetentionLimit(plantId, keepCount: _retentionLimit);
    for (final row in overflow) {
      if (row.photoPath != null) {
        await _photoStorage.deletePhoto(row.photoPath!);
      }
      await _dao.deleteById(row.id);
      // TODO(sync): Enqueue soft-delete for these pruned entries if needed
    }

    // Remove any photos on disk that are no longer referenced by any entry
    final referenced = await _dao.getPhotoPathsForPlant(plantId);
    await _photoStorage.cleanOrphanPhotos(referenced);
  }

  static EntryModel _fromRow(EntriesTableData row) => EntryModel(
        id: row.id,
        plantId: row.plantId,
        date: row.date,
        photoPath: row.photoPath,
        note: row.note,
        type: row.type,
        createdAt: row.createdAt,
        syncStatus: row.syncStatus,
      );

  static EntriesTableCompanion _toCompanion(EntryModel m) =>
      EntriesTableCompanion.insert(
        id: m.id,
        plantId: m.plantId,
        date: m.date,
        photoPath: Value(m.photoPath),
        note: Value(m.note),
        type: m.type,
        createdAt: m.createdAt,
        syncStatus: Value(m.syncStatus),
      );
}
