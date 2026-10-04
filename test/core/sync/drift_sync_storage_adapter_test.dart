import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/sync/drift_sync_storage_adapter.dart';
import 'package:polypodium/core/sync/models/entity_change.dart';

void main() {
  late AppDatabase db;
  late DriftSyncStorageAdapter adapter;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    adapter = DriftSyncStorageAdapter(db);
  });

  tearDown(() async => db.close());

  test('localChangesSince merge-sorts across entity types by rev', () async {
    await db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: 'loc1',
      name: 'Location 1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      localRev: const Value(2),
    ));
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: 'Sci',
      popularName: 'Pop',
      recommendedSoilTypes: const [],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      localRev: const Value(1),
    ));
    await db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Planta',
      soilType: 'sandy',
      acquisitionDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      localRev: const Value(3),
    ));

    final changes =
        await adapter.localChangesSince(0, limit: 100, deviceId: 'device-1');

    expect(changes.map((c) => c.rev), [1, 2, 3]);
    expect(changes.map((c) => c.entityType), ['species', 'location', 'plant']);
    expect(changes.every((c) => c.deviceId == 'device-1'), isTrue);
  });

  test('localChangesSince respects the limit across types', () async {
    await db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: 'loc1',
      name: 'Location 1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      localRev: const Value(1),
    ));
    await db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: 'loc2',
      name: 'Location 2',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      localRev: const Value(2),
    ));
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: 'Sci',
      popularName: 'Pop',
      recommendedSoilTypes: const [],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      localRev: const Value(3),
    ));

    final changes =
        await adapter.localChangesSince(0, limit: 2, deviceId: 'device-1');

    expect(changes.map((c) => c.rev), [1, 2]);
  });

  test('localChangesSince includes tombstoned (soft-deleted) rows', () async {
    await db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: 'loc1',
      name: 'Location 1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      localRev: const Value(1),
    ));
    await db.locationsDao.softDelete('loc1',
        deletedAt: DateTime(2026, 1, 2), rev: 2);

    final changes =
        await adapter.localChangesSince(0, limit: 100, deviceId: 'device-1');

    expect(changes, hasLength(1));
    expect(changes.single.deletedAt, isNotNull);
  });

  test('applyRemoteChange rejects an older update (LWW)', () async {
    await db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: 'loc1',
      name: 'Newer name',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 6, 1),
      localRev: const Value(5),
    ));

    final change = (await adapter.localChangesSince(0,
            limit: 100, deviceId: 'device-2'))
        .single;
    final olderChange = EntityChange(
      entityType: change.entityType,
      entityId: change.entityId,
      payload: {...change.payload, 'name': 'Older name'},
      updatedAt: DateTime(2026, 1, 1),
      deviceId: 'device-2',
      rev: change.rev,
    );

    await adapter.applyRemoteChange(olderChange);

    final row = await db.locationsDao.getById('loc1');
    expect(row!.name, 'Newer name');
  });

  group('plant status', () {
    Map<String, dynamic> plantPayload() => {
          'id': 'plant1',
          'speciesId': 'species1',
          'nickname': 'Planta',
          'soilId': 'sandy',
          'irrigationFrequencyDays': null,
          'acquisitionDate': DateTime(2026, 1, 1).toIso8601String(),
          'location': null,
          'locationId': null,
          'lastIrrigatedAt': null,
          'lastPesticideAppliedAt': null,
          'pesticideReapplicationDays': null,
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        };

    EntityChange plantChange(Map<String, dynamic> payload) => EntityChange(
          entityType: 'plant',
          entityId: 'plant1',
          payload: payload,
          updatedAt: DateTime(2026, 2, 1),
          deviceId: 'device-2',
          rev: 1,
        );

    test('is serialized in the outgoing payload', () async {
      await db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        status: const Value(PlantStatus.dead),
        statusChangedAt: Value(DateTime(2026, 3, 1)),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        localRev: const Value(1),
      ));

      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload['status'], 'dead');
      expect(change.payload['statusChangedAt'],
          DateTime(2026, 3, 1).toIso8601String());
    });

    test('is applied from a remote change', () async {
      await adapter.applyRemoteChange(plantChange({
        ...plantPayload(),
        'status': 'donated',
        'statusChangedAt': DateTime(2026, 3, 1).toIso8601String(),
      }));

      final row = await db.plantsDao.getById('plant1');
      expect(row!.status, PlantStatus.donated);
      expect(row.statusChangedAt, DateTime(2026, 3, 1));
    });

    test('defaults to active when an older client omits it', () async {
      await adapter.applyRemoteChange(plantChange(plantPayload()));

      final row = await db.plantsDao.getById('plant1');
      expect(row!.status, PlantStatus.active);
      expect(row.statusChangedAt, isNull);
    });

    test('falls back to active for an unknown value', () async {
      await adapter.applyRemoteChange(
          plantChange({...plantPayload(), 'status': 'composted'}));

      final row = await db.plantsDao.getById('plant1');
      expect(row!.status, PlantStatus.active);
    });
  });
}
