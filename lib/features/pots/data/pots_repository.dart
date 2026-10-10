import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../../entries/data/entries_repository.dart';
import '../../entries/domain/entry_details.dart';
import '../../entries/domain/entry_model.dart';
import '../domain/pot_model.dart';
import 'pots_dao.dart';

/// Pots and the plants in them. Every plant row this touches is a regular
/// local write (fresh rev and `updatedAt`), so moves and the location
/// cascade reach other devices like any edit.
class PotsRepository {
  PotsRepository(AppDatabase db, this._entries)
      : _db = db,
        _dao = db.potsDao;

  final AppDatabase _db;
  final PotsDao _dao;
  final EntriesRepository _entries;

  Future<List<PotModel>> getAll() async =>
      (await _dao.getAll()).map(_fromRow).toList();

  Stream<List<PotModel>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_fromRow).toList());

  Future<PotModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _fromRow(row);
  }

  /// Saves [pot]. When its location changed to another one, the live plants
  /// in it move there too (each plant can still be moved on its own later).
  Future<void> save(PotModel pot) => _db.transaction(() async {
        final existing = await _dao.getById(pot.id);
        final now = DateTime.now();
        final rev = await _db.syncMetaDao.nextRev();
        await _dao.upsert(_toCompanion(pot, updatedAt: now, rev: rev));
        if (pot.locationId != null &&
            existing != null &&
            existing.locationId != pot.locationId) {
          await _cascadeLocation(pot.id, pot.locationId, now);
        }
      });

  /// Moves the pot to [locationId] along with every live plant in it, even
  /// those that had been moved elsewhere on their own.
  Future<void> moveToLocation(String potId, String? locationId) =>
      _db.transaction(() async {
        final row = await _dao.getById(potId);
        if (row == null) return;
        final now = DateTime.now();
        final rev = await _db.syncMetaDao.nextRev();
        await _dao.upsert(_toCompanion(
            _fromRow(row).copyWith(locationId: locationId),
            updatedAt: now,
            rev: rev));
        if (locationId != null) {
          await _cascadeLocation(potId, locationId, now);
        }
      });

  Future<void> _cascadeLocation(
      String potId, String? locationId, DateTime now) async {
    for (final plant in await _db.plantsDao.getByPot(potId)) {
      if (plant.locationId == locationId) continue;
      final rev = await _db.syncMetaDao.nextRev();
      await _db.plantsDao
          .updateLocation(plant.id, locationId, updatedAt: now, rev: rev);
    }
  }

  /// Soft-deletes the pot, taking its plants out of it first (the
  /// `KeyAction.setNull` a soft delete never triggers). Returns how many
  /// plants were in it.
  Future<int> delete(String id) => _db.transaction(() async {
        final now = DateTime.now();
        final plants = await _db.plantsDao.getByPot(id);
        for (final plant in plants) {
          final rev = await _db.syncMetaDao.nextRev();
          await _db.plantsDao
              .updatePot(plant.id, null, updatedAt: now, rev: rev);
        }
        final rev = await _db.syncMetaDao.nextRev();
        await _dao.softDelete(id, deletedAt: now, rev: rev);
        return plants.length;
      });

  /// Puts the plant in [potId] (null: takes it out of its pot). A pot with
  /// a location brings the plant there, unless [applyPotLocation] is false.
  /// With [recordEntry], the move lands in the plant's diary as a repotting
  /// entry. Returns whether the plant changed pot.
  Future<bool> movePlantToPot(String plantId, String? potId,
      {bool recordEntry = true, bool applyPotLocation = true}) async {
    final moved = await movePlantsToPot([plantId], potId,
        recordEntry: recordEntry, applyPotLocation: applyPotLocation);
    return moved.isNotEmpty;
  }

  /// [movePlantToPot] for several plants at once. Returns the ids of the
  /// plants that changed pot.
  Future<List<String>> movePlantsToPot(Iterable<String> plantIds, String? potId,
      {bool recordEntry = true, bool applyPotLocation = true}) async {
    final entries = <EntryModel>[];
    final moved = <String>[];
    await _db.transaction(() async {
      final pot = potId == null ? null : await _dao.getById(potId);
      if (potId != null && (pot == null || pot.deletedAt != null)) {
        throw ArgumentError.value(potId, 'potId', 'no such pot');
      }
      final now = DateTime.now();
      for (final plantId in plantIds) {
        final plant = await _db.plantsDao.getById(plantId);
        if (plant == null || plant.deletedAt != null) continue;
        if (plant.potId == potId) continue;
        final rev = await _db.syncMetaDao.nextRev();
        final location = pot?.locationId;
        await _db.plantsDao.updatePot(plantId, potId,
            locationId: applyPotLocation && location != null
                ? Value(location)
                : const Value.absent(),
            updatedAt: now,
            rev: rev);
        moved.add(plantId);
        if (recordEntry) {
          entries.add(EntryModel(
            id: const Uuid().v4(),
            plantId: plantId,
            date: now,
            type: EntryType.repotting,
            extraData: RepottingDetails(
              potDiameterCm: pot?.diameterCm,
              potMaterial: pot?.material,
              fromPotId: plant.potId,
              toPotId: pot?.id,
              toPotName: pot?.name,
            ).encode(),
            createdAt: now,
          ));
        }
      }
    });
    for (final entry in entries) {
      await _entries.create(entry);
    }
    return moved;
  }

  /// Ids of the active plants in [potId] right now: those an entry recorded
  /// for the pot goes to.
  Future<List<String>> activePlantIds(String potId) async => [
        for (final p in await _db.plantsDao.getByPot(potId))
          if (p.status == PlantStatus.active) p.id,
      ];

  /// Moves every live plant of [fromPotId] to [toPotId] (null: out of any
  /// pot), e.g. when transplanting them all to a bigger pot.
  Future<List<String>> moveAllPlants(String fromPotId, String? toPotId,
      {bool recordEntry = true}) async {
    final plants = await _db.plantsDao.getByPot(fromPotId);
    return movePlantsToPot([for (final p in plants) p.id], toPotId,
        recordEntry: recordEntry);
  }

  static PotModel _fromRow(PotsTableData row) => PotModel(
        id: row.id,
        name: row.name,
        kind: row.kind,
        diameterCm: row.diameterCm,
        material: row.material,
        locationId: row.locationId,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        localRev: row.localRev,
      );

  PotsTableCompanion _toCompanion(PotModel m,
          {required DateTime updatedAt, required int rev}) =>
      PotsTableCompanion.insert(
        id: m.id,
        name: m.name,
        kind: Value(m.kind),
        diameterCm: Value(m.diameterCm),
        material: Value(m.material),
        locationId: Value(m.locationId),
        notes: Value(m.notes),
        createdAt: m.createdAt,
        updatedAt: updatedAt,
        localRev: Value(rev),
        deviceId: Value(_db.deviceId),
      );
}
