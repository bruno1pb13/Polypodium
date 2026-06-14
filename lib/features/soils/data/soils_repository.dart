import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/sync_queue_dao.dart';
import '../domain/soil_model.dart';

class SoilsRepository {
  SoilsRepository(AppDatabase db)
      : _db = db,
        _syncQueueDao = db.syncQueueDao;

  final AppDatabase _db;
  final SyncQueueDao _syncQueueDao;

  Future<List<SoilModel>> getAll() async {
    final rows = await _db.soilsDao.getAllSoils();
    return rows.map(_toModel).toList();
  }

  Stream<List<SoilModel>> watchAll() {
    return _db.soilsDao.watchAllSoils().map(
          (rows) => rows.map(_toModel).toList(),
        );
  }

  Future<void> save(SoilModel model) async {
    final companion = SoilsTableCompanion(
      id: Value(model.id),
      name: Value(model.name),
      composition: Value(model.composition),
      imagePath: Value(model.imagePath),
      imageSource: Value(model.imageSource),
      createdAt: Value(model.createdAt),
      syncStatus: Value(model.syncStatus),
    );
    await _db.soilsDao.insertSoil(companion);
    await _syncQueueDao.enqueue(
      entityType: 'soil',
      entityId: model.id,
      operation: 'create',
      payload: model.toJsonString(),
    );
  }

  Future<void> delete(String id) async {
    await _db.soilsDao.deleteSoil(id);
    await _syncQueueDao.enqueue(
      entityType: 'soil',
      entityId: id,
      operation: 'delete',
      payload: '{"id":"$id"}',
    );
  }

  SoilModel _toModel(SoilsTableData row) {
    return SoilModel(
      id: row.id,
      name: row.name,
      composition: row.composition,
      imagePath: row.imagePath,
      imageSource: row.imageSource,
      createdAt: row.createdAt,
      syncStatus: row.syncStatus,
    );
  }
}
