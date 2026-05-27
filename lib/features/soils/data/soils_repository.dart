import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../domain/soil_model.dart';

class SoilsRepository {
  final AppDatabase _db;

  SoilsRepository(this._db);

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
      createdAt: Value(model.createdAt),
      syncStatus: Value(model.syncStatus),
    );
    await _db.soilsDao.insertSoil(companion);
  }

  Future<void> delete(String id) async {
    await _db.soilsDao.deleteSoil(id);
  }

  SoilModel _toModel(SoilsTableData row) {
    return SoilModel(
      id: row.id,
      name: row.name,
      composition: row.composition,
      createdAt: row.createdAt,
      syncStatus: row.syncStatus,
    );
  }
}
