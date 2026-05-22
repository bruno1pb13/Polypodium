import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../../../core/notifications/notification_service.dart';
import '../../species/data/species_repository.dart';
import '../domain/plant_model.dart';
import 'plants_dao.dart';

class PlantsRepository {
  PlantsRepository(AppDatabase db)
      : _db = db,
        _dao = db.plantsDao,
        _syncQueueDao = db.syncQueueDao,
        _speciesRepo = SpeciesRepository(db);

  final AppDatabase _db;
  final PlantsDao _dao;
  final _syncQueueDao;
  final SpeciesRepository _speciesRepo;


  Future<List<PlantModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_fromRow).toList();
  }

  Stream<List<PlantModel>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_fromRow).toList());

  Future<PlantModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _fromRow(row);
  }

  Future<void> save(PlantModel plant) async {
    await _dao.upsert(_toCompanion(plant));
    // TODO(sync): Enqueue for server sync
    await _syncQueueDao.enqueue(
      entityType: 'plant',
      entityId: plant.id,
      operation: 'upsert',
      payload: plant.toJsonString(),
    );
    await _rescheduleNotification(plant);
  }

  /// Records an irrigation event and updates lastIrrigatedAt.
  Future<PlantModel?> irrigate(String plantId) async {
    final now = DateTime.now();
    await _dao.updateLastIrrigated(plantId, now);
    // TODO(sync): Enqueue irrigation update for server sync
    await _syncQueueDao.enqueue(
      entityType: 'plant',
      entityId: plantId,
      operation: 'irrigate',
      payload: '{"id":"$plantId","lastIrrigatedAt":"${now.toIso8601String()}"}',
    );
    final updated = await getById(plantId);
    if (updated != null) await _rescheduleNotification(updated);
    return updated;
  }

  /// Recalculates lastIrrigatedAt based on the most recent irrigation entry.
  Future<void> refreshPlantStatus(String plantId) async {
    final lastDate = await _db.entriesDao.getLastIrrigationDate(plantId);
    await _dao.updateLastIrrigated(plantId, lastDate);
    final plant = await getById(plantId);
    if (plant != null) {
      await _rescheduleNotification(plant);
    }
  }

  Future<void> delete(String id) async {

    await NotificationService.cancelNotification(id);
    await _dao.deleteById(id);
    // TODO(sync): Enqueue deletion for server sync
    await _syncQueueDao.enqueue(
      entityType: 'plant',
      entityId: id,
      operation: 'delete',
      payload: '{"id":"$id"}',
    );
  }

  // ---------------------------------------------------------------------------

  Future<void> _rescheduleNotification(PlantModel plant) async {
    final species = await _speciesRepo.getById(plant.speciesId);
    if (species == null) return;
    await NotificationService.scheduleIrrigationNotification(
      plant: plant,
      species: species,
    );
  }

  static PlantModel _fromRow(PlantsTableData row) => PlantModel(
        id: row.id,
        speciesId: row.speciesId,
        nickname: row.nickname,
        soilType: row.soilType,
        irrigationFrequencyDays: row.irrigationFrequencyDays,
        acquisitionDate: row.acquisitionDate,
        location: row.location,
        locationId: row.locationId,
        lastIrrigatedAt: row.lastIrrigatedAt,
        createdAt: row.createdAt,
        syncStatus: row.syncStatus,
      );

  static PlantsTableCompanion _toCompanion(PlantModel m) =>
      PlantsTableCompanion.insert(
        id: m.id,
        speciesId: m.speciesId,
        nickname: m.nickname,
        soilType: m.soilType,
        irrigationFrequencyDays: Value(m.irrigationFrequencyDays),
        acquisitionDate: m.acquisitionDate,
        location: Value(m.location),
        locationId: Value(m.locationId),
        lastIrrigatedAt: Value(m.lastIrrigatedAt),
        createdAt: m.createdAt,
        syncStatus: Value(m.syncStatus),
      );
}
