import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../domain/defensivo_model.dart';

class DefensivosRepository {
  DefensivosRepository(AppDatabase db) : _db = db;

  final AppDatabase _db;

  Future<List<DefensivoModel>> getAll() async {
    final rows = await _db.defensivosDao.getAllDefensivos();
    return rows.map(_toModel).toList();
  }

  Stream<List<DefensivoModel>> watchAll() {
    return _db.defensivosDao.watchAllDefensivos().map(
          (rows) => rows.map(_toModel).toList(),
        );
  }

  Future<void> save(DefensivoModel model) async {
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      final companion = DefensivosTableCompanion.insert(
        id: model.id,
        name: model.name,
        category: Value(model.category?.name),
        customCategoryLabel: Value(model.customCategoryLabel),
        composition: Value(model.composition),
        carenciaDays: Value(model.carenciaDays),
        imagePath: Value(model.imagePath),
        imageSource: Value(model.imageSource),
        createdAt: model.createdAt,
        updatedAt: DateTime.now(),
        localRev: Value(rev),
      );
      await _db.defensivosDao.insertDefensivo(companion);
    });
  }

  /// A defensivo referenced by a past entry is denormalized (name + id
  /// copied into the entry's extraData at launch time), so deleting it from
  /// the catalog never invalidates history — no "in use" guard needed.
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _db.defensivosDao
          .softDelete(id, deletedAt: DateTime.now(), rev: rev);
    });
  }

  DefensivoModel _toModel(DefensivosTableData row) {
    return DefensivoModel(
      id: row.id,
      name: row.name,
      category: row.category != null
          ? DefensivoCategory.values.byName(row.category!)
          : null,
      customCategoryLabel: row.customCategoryLabel,
      composition: row.composition,
      carenciaDays: row.carenciaDays,
      imagePath: row.imagePath,
      imageSource: row.imageSource,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      localRev: row.localRev,
    );
  }
}
