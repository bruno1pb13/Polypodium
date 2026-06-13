import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/sync_queue_dao.dart';
import '../domain/location_model.dart';
import 'locations_dao.dart';

class LocationsRepository {
  LocationsRepository(AppDatabase db)
      : _dao = db.locationsDao,
        _syncQueueDao = db.syncQueueDao;

  final LocationsDao _dao;
  final SyncQueueDao _syncQueueDao;

  Future<List<LocationModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_fromRow).toList();
  }

  Stream<List<LocationModel>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_fromRow).toList());

  Future<LocationModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _fromRow(row);
  }

  Future<void> save(LocationModel location) async {
    await _dao.upsert(_toCompanion(location));
    await _syncQueueDao.enqueue(
      entityType: 'location',
      entityId: location.id,
      operation: 'create',
      payload: location.toJsonString(),
    );
  }

  Future<void> delete(String id) async {
    await _dao.deleteById(id);
    await _syncQueueDao.enqueue(
      entityType: 'location',
      entityId: id,
      operation: 'delete',
      payload: '{"id":"$id"}',
    );
  }

  static LocationModel _fromRow(LocationsTableData row) => LocationModel(
        id: row.id,
        name: row.name,
        description: row.description,
        latitude: row.latitude,
        longitude: row.longitude,
        createdAt: row.createdAt,
        syncStatus: row.syncStatus,
      );

  static LocationsTableCompanion _toCompanion(LocationModel m) =>
      LocationsTableCompanion.insert(
        id: m.id,
        name: m.name,
        description: Value(m.description),
        latitude: Value(m.latitude),
        longitude: Value(m.longitude),
        createdAt: m.createdAt,
        syncStatus: Value(m.syncStatus),
      );
}
