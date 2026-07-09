import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../species/data/species_repository.dart';
import '../domain/plant_model.dart';
import 'plants_dao.dart';

class PlantsRepository {
  PlantsRepository(
    AppDatabase db,
    INotificationService notifications, {
    SpeciesRepository? speciesRepo,
  })  : _db = db,
        _dao = db.plantsDao,
        _speciesRepo = speciesRepo ?? SpeciesRepository(db),
        _notifications = notifications;

  final AppDatabase _db;
  final PlantsDao _dao;
  final SpeciesRepository _speciesRepo;
  final INotificationService _notifications;

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
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao
          .upsert(_toCompanion(plant, updatedAt: DateTime.now(), rev: rev));
    });
    await _rescheduleNotification(plant);
  }

  /// Records an irrigation event and updates lastIrrigatedAt.
  Future<PlantModel?> irrigate(String plantId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.updateLastIrrigated(plantId, now, updatedAt: now, rev: rev);
    });
    final updated = await getById(plantId);
    if (updated != null) {
      await _rescheduleNotification(updated);
    }
    return updated;
  }

  /// Recalculates lastIrrigatedAt based on the most recent irrigation entry.
  Future<void> refreshPlantStatus(String plantId) async {
    final lastDate = await _db.entriesDao.getLastIrrigationDate(plantId);
    await _db.transaction(() async {
      final rev = await _db.syncMetaDao.nextRev();
      await _dao.updateLastIrrigated(plantId, lastDate,
          updatedAt: DateTime.now(), rev: rev);
    });
    final plant = await getById(plantId);
    if (plant != null) {
      await _rescheduleNotification(plant);
    }
  }

  Future<void> delete(String id) async {
    await _notifications.cancel(id);
    final now = DateTime.now();
    await _db.transaction(() async {
      // Replicates the `KeyAction.cascade` FK behavior that only fires on a
      // real SQLite DELETE, which a soft-delete never triggers.
      final entryRev = await _db.syncMetaDao.nextRev();
      await _db.entriesDao
          .softDeleteByPlant(id, deletedAt: now, rev: entryRev);
      final plantRev = await _db.syncMetaDao.nextRev();
      await _dao.softDelete(id, deletedAt: now, rev: plantRev);
    });
  }

  // ---------------------------------------------------------------------------

  Future<void> _rescheduleNotification(PlantModel plant) async {
    final species = await _speciesRepo.getById(plant.speciesId);
    if (species == null) {
      // ignore: avoid_print
      print(
          '[PlantsRepository] Species ${plant.speciesId} not found for plant '
          '${plant.id}; irrigation notification skipped');
      return;
    }
    await _notifications.schedule(plant: plant, species: species);
  }

  static PlantModel _fromRow(PlantsTableData row) => PlantModel(
        id: row.id,
        speciesId: row.speciesId,
        nickname: row.nickname,
        soilId: row.soilType,
        irrigationFrequencyDays: row.irrigationFrequencyDays,
        acquisitionDate: row.acquisitionDate,
        location: row.location,
        locationId: row.locationId,
        lastIrrigatedAt: row.lastIrrigatedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        localRev: row.localRev,
      );

  static PlantsTableCompanion _toCompanion(PlantModel m,
          {required DateTime updatedAt, required int rev}) =>
      PlantsTableCompanion.insert(
        id: m.id,
        speciesId: m.speciesId,
        nickname: m.nickname,
        soilType: m.soilId,
        irrigationFrequencyDays: Value(m.irrigationFrequencyDays),
        acquisitionDate: m.acquisitionDate,
        location: Value(m.location),
        locationId: Value(m.locationId),
        lastIrrigatedAt: Value(m.lastIrrigatedAt),
        createdAt: m.createdAt,
        updatedAt: updatedAt,
        localRev: Value(rev),
      );
}
