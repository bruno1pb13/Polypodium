import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain_exceptions.dart';
import '../domain/species_model.dart';
import 'species_dao.dart';

class SpeciesRepository {
  SpeciesRepository(AppDatabase db)
      : _db = db,
        _dao = db.speciesDao;

  final AppDatabase _db;
  final SpeciesDao _dao;

  Future<List<SpeciesModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_fromRow).toList();
  }

  Stream<List<SpeciesModel>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_fromRow).toList());

  Future<SpeciesModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _fromRow(row);
  }

  Future<void> save(SpeciesModel species) async {
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao
          .upsert(_toCompanion(species, updatedAt: DateTime.now(), rev: rev));
    });
  }

  Future<void> delete(String id) async {
    final hasActivePlants =
        await _db.plantsDao.hasActiveReferencingSpecies(id);
    if (hasActivePlants) {
      throw const SpeciesInUseException();
    }
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.softDelete(id, deletedAt: DateTime.now(), rev: rev);
    });
  }

  // ---------------------------------------------------------------------------

  static SpeciesModel _fromRow(SpeciesTableData row) => SpeciesModel(
        id: row.id,
        scientificName: row.scientificName,
        popularName: row.popularName,
        defaultIrrigationFrequencyDays: row.defaultIrrigationFrequencyDays,
        recommendedSoilIds: row.recommendedSoilTypes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        localRev: row.localRev,
      );

  static SpeciesTableCompanion _toCompanion(SpeciesModel m,
          {required DateTime updatedAt, required int rev}) =>
      SpeciesTableCompanion.insert(
        id: m.id,
        scientificName: m.scientificName,
        popularName: m.popularName,
        defaultIrrigationFrequencyDays:
            Value(m.defaultIrrigationFrequencyDays),
        recommendedSoilTypes: m.recommendedSoilIds,
        createdAt: m.createdAt,
        updatedAt: updatedAt,
        localRev: Value(rev),
      );
}
