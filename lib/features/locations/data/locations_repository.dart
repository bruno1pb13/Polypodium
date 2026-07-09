import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/location_model.dart';
import 'locations_dao.dart';

class LocationsRepository {
  LocationsRepository(AppDatabase db)
      : _db = db,
        _dao = db.locationsDao;

  final AppDatabase _db;
  final LocationsDao _dao;

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
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.upsert(
          _toCompanion(location, updatedAt: DateTime.now(), rev: rev));
    });
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      // Replicates the `KeyAction.setNull` FK behavior that only fires on a
      // real SQLite DELETE, which a soft-delete never triggers.
      final clearRev = await _db.syncMetaDao.nextRev();
      await _db.plantsDao
          .clearLocationForPlants(id, updatedAt: now, rev: clearRev);
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.softDelete(id, deletedAt: now, rev: rev);
    });
  }

  static LocationModel _fromRow(LocationsTableData row) => LocationModel(
        id: row.id,
        name: row.name,
        description: row.description,
        latitude: row.latitude,
        longitude: row.longitude,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        localRev: row.localRev,
      );

  static LocationsTableCompanion _toCompanion(LocationModel m,
          {required DateTime updatedAt, required int rev}) =>
      LocationsTableCompanion.insert(
        id: m.id,
        name: m.name,
        description: Value(m.description),
        latitude: Value(m.latitude),
        longitude: Value(m.longitude),
        createdAt: m.createdAt,
        updatedAt: updatedAt,
        localRev: Value(rev),
      );
}
