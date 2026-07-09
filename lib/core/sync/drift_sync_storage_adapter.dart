import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../enums.dart';
import 'i_sync_storage_adapter.dart';
import 'lww_merge.dart';
import 'models/entity_change.dart';

/// Drift-backed implementation of the sync storage contract. Absorbs the
/// per-entity read/apply logic that used to live in SyncService's
/// `_applyXEvent` methods -- now unified into a single "LWW-compare, then
/// upsert the full row" path per type, since every change now carries the
/// complete row plus a `deletedAt` flag rather than a create/update/delete
/// operation tag.
class DriftSyncStorageAdapter implements ISyncStorageAdapter {
  DriftSyncStorageAdapter(this._db);

  final AppDatabase _db;

  static const _entityTypes = [
    'species',
    'soil',
    'location',
    'plant',
    'entry',
  ];

  @override
  Future<List<EntityChange>> localChangesSince(
    int since, {
    required int limit,
    required String deviceId,
  }) async {
    final candidates = <EntityChange>[];

    for (final entityType in _entityTypes) {
      final rows = await _changesSinceFor(entityType, since, limit + 1);
      for (final row in rows) {
        candidates.add(_toChange(entityType, row, deviceId));
      }
    }

    candidates.sort((a, b) => a.rev.compareTo(b.rev));
    return candidates.length > limit
        ? candidates.sublist(0, limit)
        : candidates;
  }

  @override
  Future<void> applyRemoteChange(EntityChange change) async {
    switch (change.entityType) {
      case 'species':
        await _applySpecies(change);
      case 'plant':
        await _applyPlant(change);
      case 'entry':
        await _applyEntry(change);
      case 'location':
        await _applyLocation(change);
      case 'soil':
        await _applySoil(change);
    }
  }

  // -- read side -------------------------------------------------------------

  Future<List<dynamic>> _changesSinceFor(
      String entityType, int since, int limit) {
    switch (entityType) {
      case 'species':
        return _db.speciesDao.changesSince(since, limit: limit);
      case 'plant':
        return _db.plantsDao.changesSince(since, limit: limit);
      case 'entry':
        return _db.entriesDao.changesSince(since, limit: limit);
      case 'location':
        return _db.locationsDao.changesSince(since, limit: limit);
      case 'soil':
        return _db.soilsDao.changesSince(since, limit: limit);
      default:
        throw ArgumentError('Unknown entityType: $entityType');
    }
  }

  EntityChange _toChange(String entityType, dynamic row, String deviceId) {
    late final Map<String, dynamic> payload;
    late final DateTime updatedAt;
    late final DateTime? deletedAt;
    late final int rev;
    late final String entityId;

    switch (entityType) {
      case 'species':
        final r = row as SpeciesTableData;
        entityId = r.id;
        updatedAt = r.updatedAt;
        deletedAt = r.deletedAt;
        rev = r.localRev;
        payload = {
          'id': r.id,
          'scientificName': r.scientificName,
          'popularName': r.popularName,
          'defaultIrrigationFrequencyDays': r.defaultIrrigationFrequencyDays,
          'recommendedSoilIds': r.recommendedSoilTypes,
          'createdAt': r.createdAt.toIso8601String(),
        };
      case 'plant':
        final r = row as PlantsTableData;
        entityId = r.id;
        updatedAt = r.updatedAt;
        deletedAt = r.deletedAt;
        rev = r.localRev;
        payload = {
          'id': r.id,
          'speciesId': r.speciesId,
          'nickname': r.nickname,
          'soilId': r.soilType,
          'irrigationFrequencyDays': r.irrigationFrequencyDays,
          'acquisitionDate': r.acquisitionDate.toIso8601String(),
          'location': r.location,
          'locationId': r.locationId,
          'lastIrrigatedAt': r.lastIrrigatedAt?.toIso8601String(),
          'createdAt': r.createdAt.toIso8601String(),
        };
      case 'entry':
        final r = row as EntriesTableData;
        entityId = r.id;
        updatedAt = r.updatedAt;
        deletedAt = r.deletedAt;
        rev = r.localRev;
        payload = {
          'id': r.id,
          'plantId': r.plantId,
          'date': r.date.toIso8601String(),
          'photoPath': r.photoPath,
          'note': r.note,
          'type': r.type.name,
          'numericValue': r.numericValue,
          'extraData': r.extraData,
          'createdAt': r.createdAt.toIso8601String(),
        };
      case 'location':
        final r = row as LocationsTableData;
        entityId = r.id;
        updatedAt = r.updatedAt;
        deletedAt = r.deletedAt;
        rev = r.localRev;
        payload = {
          'id': r.id,
          'name': r.name,
          'description': r.description,
          'latitude': r.latitude,
          'longitude': r.longitude,
          'createdAt': r.createdAt.toIso8601String(),
        };
      case 'soil':
        final r = row as SoilsTableData;
        entityId = r.id;
        updatedAt = r.updatedAt;
        deletedAt = r.deletedAt;
        rev = r.localRev;
        payload = {
          'id': r.id,
          'name': r.name,
          'composition': r.composition,
          'imagePath': r.imagePath,
          'imageSource': r.imageSource,
          'createdAt': r.createdAt.toIso8601String(),
        };
      default:
        throw ArgumentError('Unknown entityType: $entityType');
    }

    return EntityChange(
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      deviceId: deviceId,
      rev: rev,
    );
  }

  // -- apply side ------------------------------------------------------------

  Future<void> _applySpecies(EntityChange change) async {
    final existing = await _db.speciesDao.getById(change.entityId);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: change.updatedAt)) {
      return;
    }
    final p = change.payload;
    final soilIds = (p['recommendedSoilIds'] as List<dynamic>?)?.cast<String>() ?? [];
    await _db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: change.entityId,
      scientificName: p['scientificName'] as String,
      popularName: p['popularName'] as String,
      defaultIrrigationFrequencyDays:
          Value(p['defaultIrrigationFrequencyDays'] as int?),
      recommendedSoilTypes: soilIds,
      createdAt: DateTime.parse(p['createdAt'] as String),
      updatedAt: change.updatedAt,
      deletedAt: Value(change.deletedAt),
      localRev: const Value(0),
    ));
  }

  Future<void> _applyPlant(EntityChange change) async {
    final existing = await _db.plantsDao.getById(change.entityId);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: change.updatedAt)) {
      return;
    }
    final p = change.payload;
    await _db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: change.entityId,
      speciesId: p['speciesId'] as String,
      nickname: p['nickname'] as String,
      soilType: (p['soilId'] ?? p['soilType']) as String,
      irrigationFrequencyDays: Value(p['irrigationFrequencyDays'] as int?),
      acquisitionDate: DateTime.parse(p['acquisitionDate'] as String),
      location: Value(p['location'] as String?),
      locationId: Value(p['locationId'] as String?),
      lastIrrigatedAt: Value(p['lastIrrigatedAt'] != null
          ? DateTime.parse(p['lastIrrigatedAt'] as String)
          : null),
      createdAt: DateTime.parse(p['createdAt'] as String),
      updatedAt: change.updatedAt,
      deletedAt: Value(change.deletedAt),
      localRev: const Value(0),
    ));
  }

  Future<void> _applyEntry(EntityChange change) async {
    final existing = await _db.entriesDao.getById(change.entityId);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: change.updatedAt)) {
      return;
    }
    final p = change.payload;
    await _db.entriesDao.upsert(EntriesTableCompanion.insert(
      id: change.entityId,
      plantId: p['plantId'] as String,
      date: DateTime.parse(p['date'] as String),
      photoPath: Value(p['photoPath'] as String?),
      note: Value(p['note'] as String?),
      type: EntryType.values.byName(p['type'] as String),
      numericValue: Value((p['numericValue'] as num?)?.toDouble()),
      extraData: Value(p['extraData'] as String?),
      createdAt: DateTime.parse(p['createdAt'] as String),
      updatedAt: change.updatedAt,
      deletedAt: Value(change.deletedAt),
      localRev: const Value(0),
    ));

    if (change.deletedAt == null &&
        EntryType.values.byName(p['type'] as String) == EntryType.irrigation) {
      // Recomputing lastIrrigatedAt from entries is a locally-derived fact,
      // not itself remote data -- stamp it as a fresh local write (own
      // rev/updatedAt) so it propagates on the next push, rather than
      // reusing the incoming entry's rev/timestamp.
      final plantId = p['plantId'] as String;
      final lastDate = await _db.entriesDao.getLastIrrigationDate(plantId);
      await _db.transaction(() async {
        final rev = await _db.syncMetaDao.nextRev();
        await _db.plantsDao.updateLastIrrigated(plantId, lastDate,
            updatedAt: DateTime.now(), rev: rev);
      });
    }
  }

  Future<void> _applyLocation(EntityChange change) async {
    final existing = await _db.locationsDao.getById(change.entityId);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: change.updatedAt)) {
      return;
    }
    final p = change.payload;
    await _db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: change.entityId,
      name: p['name'] as String,
      description: Value(p['description'] as String?),
      latitude: Value((p['latitude'] as num?)?.toDouble()),
      longitude: Value((p['longitude'] as num?)?.toDouble()),
      createdAt: DateTime.parse(p['createdAt'] as String),
      updatedAt: change.updatedAt,
      deletedAt: Value(change.deletedAt),
      localRev: const Value(0),
    ));
  }

  Future<void> _applySoil(EntityChange change) async {
    final existing = await _db.soilsDao.getSoilById(change.entityId);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: change.updatedAt)) {
      return;
    }
    final p = change.payload;
    await _db.soilsDao.insertSoil(SoilsTableCompanion.insert(
      id: change.entityId,
      name: p['name'] as String,
      composition: Value(p['composition'] as String?),
      imagePath: Value(p['imagePath'] as String?),
      imageSource: Value(p['imageSource'] as String?),
      createdAt: DateTime.parse(p['createdAt'] as String),
      updatedAt: change.updatedAt,
      deletedAt: Value(change.deletedAt),
      localRev: const Value(0),
      // A soil arriving via sync is never a fresh local seed.
      isSeeded: const Value(false),
    ));
  }
}
