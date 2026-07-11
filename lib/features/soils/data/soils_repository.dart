import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain_exceptions.dart';
import '../domain/soil_model.dart';

class SoilsRepository {
  SoilsRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;

  Future<List<SoilModel>> getAll() async {
    final rows = await _db.soilsDao.getAllSoils();
    return rows.map(_toModel).toList();
  }

  Stream<List<SoilModel>> watchAll() {
    return _db.soilsDao.watchAllSoils().map(
          (rows) => rows.map(_toModel).toList(),
        );
  }

  /// Creating/editing a soil through this repository always counts as user
  /// data from that point on -- even if it started out as a seeded default
  /// -- so it gets picked up by WorkspaceMigrationService on first login.
  Future<void> save(SoilModel model) async {
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      final companion = SoilsTableCompanion.insert(
        id: model.id,
        name: model.name,
        composition: Value(model.composition),
        imagePath: Value(model.imagePath),
        imageSource: Value(model.imageSource),
        createdAt: model.createdAt,
        updatedAt: DateTime.now(),
        localRev: Value(rev),
        isSeeded: const Value(false),
      );
      await _db.soilsDao.insertSoil(companion);
    });
  }

  Future<void> delete(String id) async {
    final hasActivePlants = await _db.plantsDao.hasActiveReferencingSoil(id);
    if (hasActivePlants) {
      throw const SoilInUseException();
    }
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _db.soilsDao.softDelete(id, deletedAt: DateTime.now(), rev: rev);
    });
  }

  SoilModel _toModel(SoilsTableData row) {
    return SoilModel(
      id: row.id,
      name: row.name,
      composition: row.composition,
      imagePath: row.imagePath,
      imageSource: row.imageSource,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      localRev: row.localRev,
      isSeeded: row.isSeeded,
    );
  }
}
