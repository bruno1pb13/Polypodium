import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../../../core/storage/photo_storage.dart';
import '../../reminders/domain/reminder_model.dart';
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
    if (row == null) return null;
    return _fromRow(row, await _db.entryPhotosDao.getByEntries([id]));
  }

  Future<List<EntryModel>> getByPlant(String plantId) async {
    final rows = await _dao.getByPlantWithPhotos(plantId);
    return [for (final (row, photos) in rows) _fromRow(row, photos)];
  }

  Stream<List<EntryModel>> watchByPlant(String plantId) =>
      _dao.watchByPlantWithPhotos(plantId).map(
          (rows) => [for (final (row, photos) in rows) _fromRow(row, photos)]);

  /// Entries of every plant, newest first, without their extra photos.
  Stream<List<EntryModel>> watchAll() => _dao
      .watchAll()
      .map((rows) => [for (final row in rows) _fromRow(row, const [])]);

  /// Entries of every plant of one of [types], newest first, without their
  /// extra photos.
  Stream<List<EntryModel>> watchOfTypes(Iterable<EntryType> types) => _dao
      .watchOfTypes(types)
      .map((rows) => [for (final row in rows) _fromRow(row, const [])]);

  /// Saves [entry] with its extra photos, each its own synced row written
  /// after the entry so a peer applies them in that order.
  Future<void> create(EntryModel entry) async {
    assert(entry.extraPhotos.isEmpty || entry.photoPath != null);
    await _db.transaction(() async {
      final now = DateTime.now();
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.insert(_toCompanion(entry, updatedAt: now, rev: rev));
      for (final (i, photo) in entry.extraPhotos.indexed) {
        final photoRev = await _db.syncMetaDao.nextRev();
        await _db.entryPhotosDao.upsert(EntryPhotosTableCompanion.insert(
          id: photo.id,
          entryId: entry.id,
          photoPath: photo.path,
          position: Value(i + 1),
          createdAt: entry.createdAt,
          updatedAt: now,
          localRev: Value(photoRev),
          deviceId: Value(_db.deviceId),
        ));
      }
    });
    await _enforceRetentionPolicy(entry.plantId);
  }

  Future<void> delete(String id) async {
    final entry = await getById(id);
    // Guard against programming errors -- the UI never offers deletion for
    // history entries, so this is not a user-facing message.
    if (entry?.type == EntryType.history) {
      throw StateError('History entries cannot be deleted.');
    }
    await _db.transaction(() async {
      final now = DateTime.now();
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.softDelete(id, deletedAt: now, rev: rev);
      await _db.entryPhotosDao.softDeleteByEntry(id, deletedAt: now);
    });
    for (final photo in entry?.photos ?? const <EntryPhoto>[]) {
      await _photoStorage.deletePhoto(photo.path);
    }
  }

  // ---------------------------------------------------------------------------

  /// Soft-deletes entries beyond [_retentionLimit] (oldest first) and cleans
  /// orphaned photo files from disk. The latest entry of each type a
  /// recurring reminder can track is always kept: the reminder derives when
  /// the care was last done from it.
  Future<void> _enforceRetentionPolicy(String plantId) async {
    final overflow =
        await _dao.getOverRetentionLimit(plantId, keepCount: _retentionLimit);
    final keep = <String>{};
    for (final type in {for (final row in overflow) row.type}) {
      if (!reminderEntryTypes.contains(type)) continue;
      final last = await _dao.getLastEntryOfType(plantId, type);
      if (last != null) keep.add(last.id);
    }
    overflow.removeWhere((row) => keep.contains(row.id));
    if (overflow.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final photoPaths = <String>[];
    await _db.transaction(() async {
      for (final row in overflow) {
        final rev = await _db.syncMetaDao.nextRev();
        await _dao.softDelete(row.id, deletedAt: now, rev: rev);
        if (row.photoPath != null) photoPaths.add(row.photoPath!);
        final extra = await _db.entryPhotosDao
            .softDeleteByEntry(row.id, deletedAt: now);
        photoPaths.addAll(extra.map((p) => p.photoPath));
      }
    });
    for (final path in photoPaths) {
      await _photoStorage.deletePhoto(path);
    }

    // Remove any photos on disk that are no longer referenced by any entry
    final referenced = await _dao.getAllPhotoPaths();
    await _photoStorage.cleanOrphanPhotos(referenced);
  }

  static EntryModel _fromRow(
          EntriesTableData row, List<EntryPhotosTableData> photos) =>
      EntryModel(
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
        // Rows of an entry without its own photo can't be shown in order.
        extraPhotos: row.photoPath == null
            ? const []
            : [
                for (final p in photos)
                  EntryPhoto(id: p.id, path: p.photoPath),
              ],
      );

  EntriesTableCompanion _toCompanion(EntryModel m,
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
        deviceId: Value(_db.deviceId),
      );
}
