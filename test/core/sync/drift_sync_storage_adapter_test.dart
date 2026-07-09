import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:polypodium/core/database/app_database.dart';
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
}
