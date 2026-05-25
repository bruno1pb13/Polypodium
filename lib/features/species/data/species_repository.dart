import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/sync_queue_dao.dart';
import '../domain/species_model.dart';
import 'species_dao.dart';

class SpeciesRepository {
  SpeciesRepository(AppDatabase db)
      : _dao = db.speciesDao,
        _syncQueueDao = db.syncQueueDao;

  final SpeciesDao _dao;
  final SyncQueueDao _syncQueueDao;

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
    await _dao.upsert(_toCompanion(species));
    // TODO(sync): Enqueue for server sync when connectivity layer is added
    await _syncQueueDao.enqueue(
      entityType: 'species',
      entityId: species.id,
      operation: 'upsert',
      payload: species.toJsonString(),
    );
  }

  Future<void> delete(String id) async {
    await _dao.deleteById(id);
    // TODO(sync): Enqueue deletion for server sync
    await _syncQueueDao.enqueue(
      entityType: 'species',
      entityId: id,
      operation: 'delete',
      payload: '{"id":"$id"}',
    );
  }

  // ---------------------------------------------------------------------------

  static SpeciesModel _fromRow(SpeciesTableData row) => SpeciesModel(
        id: row.id,
        scientificName: row.scientificName,
        popularName: row.popularName,
        defaultIrrigationFrequencyDays: row.defaultIrrigationFrequencyDays,
        recommendedSoilTypes: row.recommendedSoilTypes,
        syncStatus: row.syncStatus,
        createdAt: row.createdAt,
      );

  static SpeciesTableCompanion _toCompanion(SpeciesModel m) =>
      SpeciesTableCompanion.insert(
        id: m.id,
        scientificName: m.scientificName,
        popularName: m.popularName,
        defaultIrrigationFrequencyDays: Value(m.defaultIrrigationFrequencyDays),
        recommendedSoilTypes: m.recommendedSoilTypes,
        syncStatus: Value(m.syncStatus),
        createdAt: m.createdAt,
      );
}
