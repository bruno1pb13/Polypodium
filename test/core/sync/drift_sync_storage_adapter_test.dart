import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium_core/polypodium_core.dart';

import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/sync/drift_sync_storage_adapter.dart';

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
    final olderChange = SyncChange(
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

    SyncChange plantChange(Map<String, dynamic> payload) => SyncChange(
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

    test('the parent plant round-trips; older clients send none', () async {
      await db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Muda',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        parentPlantId: const Value('mother'),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        localRev: const Value(1),
      ));
      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload['parentPlantId'], 'mother');

      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      final otherAdapter = DriftSyncStorageAdapter(other);
      await otherAdapter
          .applyRemoteChange(SyncChange.fromJson(change.toJson()));
      expect((await other.plantsDao.getById('plant1'))!.parentPlantId,
          'mother');

      await adapter.applyRemoteChange(plantChange(plantPayload()));
      expect((await db.plantsDao.getById('plant1'))!.parentPlantId, isNull);
    });

    test('the cover photo round-trips; older clients send none', () async {
      await db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        coverPhotoId: const Value('entry9'),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        localRev: const Value(1),
      ));
      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload['coverPhotoId'], 'entry9');

      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      await DriftSyncStorageAdapter(other)
          .applyRemoteChange(SyncChange.fromJson(change.toJson()));
      expect(
          (await other.plantsDao.getById('plant1'))!.coverPhotoId, 'entry9');

      await adapter.applyRemoteChange(plantChange(plantPayload()));
      expect((await db.plantsDao.getById('plant1'))!.coverPhotoId, isNull);
    });

    test('the pot round-trips; older clients send none', () async {
      await db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        potId: const Value('pot1'),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        localRev: const Value(1),
      ));
      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload['potId'], 'pot1');

      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      await DriftSyncStorageAdapter(other)
          .applyRemoteChange(SyncChange.fromJson(change.toJson()));
      expect((await other.plantsDao.getById('plant1'))!.potId, 'pot1');

      await adapter.applyRemoteChange(plantChange(plantPayload()));
      expect((await db.plantsDao.getById('plant1'))!.potId, isNull);
    });

    test('falls back to active for an unknown value', () async {
      await adapter.applyRemoteChange(
          plantChange({...plantPayload(), 'status': 'composted'}));

      final row = await db.plantsDao.getById('plant1');
      expect(row!.status, PlantStatus.active);
    });
  });

  group('species care sheet', () {
    Map<String, dynamic> speciesPayload() => {
          'id': 'species1',
          'scientificName': 'Ficus lyrata',
          'popularName': 'Figueira',
          'defaultIrrigationFrequencyDays': 7,
          'recommendedSoilIds': ['loamy'],
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        };

    SyncChange speciesChange(Map<String, dynamic> payload) => SyncChange(
          entityType: 'species',
          entityId: 'species1',
          payload: payload,
          updatedAt: DateTime(2026, 2, 1),
          deviceId: 'device-2',
          rev: 1,
        );

    test('round-trips through localChangesSince/applyRemoteChange',
        () async {
      await db.speciesDao.upsert(SpeciesTableCompanion.insert(
        id: 'species1',
        scientificName: 'Ficus lyrata',
        popularName: 'Figueira',
        recommendedSoilTypes: const ['loamy'],
        light: const Value(LightRequirement.indirectBright),
        humidity: const Value(HumidityLevel.medium),
        petToxicity: const Value(PetToxicity.toxic),
        floweringMonths: const Value({11, 2, 3}),
        careNotes: const Value('Girar o vaso'),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        localRev: const Value(1),
      ));

      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload['light'], 'indirectBright');
      expect(change.payload['humidity'], 'medium');
      expect(change.payload['petToxicity'], 'toxic');
      expect(change.payload['floweringMonths'], [2, 3, 11]);
      expect(change.payload['careNotes'], 'Girar o vaso');

      final peer = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(peer.close);
      await DriftSyncStorageAdapter(peer).applyRemoteChange(change);

      final row = await peer.speciesDao.getById('species1');
      expect(row!.light, LightRequirement.indirectBright);
      expect(row.humidity, HumidityLevel.medium);
      expect(row.petToxicity, PetToxicity.toxic);
      expect(row.floweringMonths, {2, 3, 11});
      expect(row.careNotes, 'Girar o vaso');
    });

    test('is left empty when an older client omits it', () async {
      await adapter.applyRemoteChange(speciesChange(speciesPayload()));

      final row = await db.speciesDao.getById('species1');
      expect(row!.scientificName, 'Ficus lyrata');
      expect(row.light, isNull);
      expect(row.humidity, isNull);
      expect(row.petToxicity, PetToxicity.unknown);
      expect(row.floweringMonths, isEmpty);
      expect(row.careNotes, isNull);
    });

    test('ignores unknown values and invalid months', () async {
      await adapter.applyRemoteChange(speciesChange({
        ...speciesPayload(),
        'light': 'moonlight',
        'humidity': 'soggy',
        'petToxicity': 'mildlyToxic',
        'floweringMonths': [0, 4, 13, '5', 4],
      }));

      final row = await db.speciesDao.getById('species1');
      expect(row!.light, isNull);
      expect(row.humidity, isNull);
      expect(row.petToxicity, PetToxicity.unknown);
      expect(row.floweringMonths, {4});
    });
  });

  group('pots (wire name bed)', () {
    test('round-trip through localChangesSince/applyRemoteChange', () async {
      await db.potsDao.upsert(PotsTableCompanion.insert(
        id: 'pot1',
        name: 'Jardineira da varanda',
        kind: const Value(PotKind.planter),
        diameterCm: const Value(60),
        material: const Value(PotMaterial.clay),
        locationId: const Value('loc1'),
        notes: const Value('Sol da tarde'),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        localRev: const Value(1),
      ));

      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.entityType, 'bed');
      expect(change.entityId, 'pot1');
      expect(change.payload['kind'], 'planter');
      expect(change.payload['material'], 'clay');

      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      await DriftSyncStorageAdapter(other)
          .applyRemoteChange(SyncChange.fromJson(change.toJson()));
      final pot = (await other.potsDao.getById('pot1'))!;
      expect(pot.name, 'Jardineira da varanda');
      expect(pot.kind, PotKind.planter);
      expect(pot.diameterCm, 60);
      expect(pot.material, PotMaterial.clay);
      expect(pot.locationId, 'loc1');
      expect(pot.notes, 'Sol da tarde');
      expect(pot.updatedAt, DateTime(2026, 1, 2));
      expect(pot.deviceId, 'device-1');
      expect(pot.localRev, 0);
    });

    test('are listed as an entity type', () {
      expect(adapter.entityTypes, contains('bed'));
    });

    test('an older update loses (LWW) and a tombstone applies', () async {
      SyncChange potChange(DateTime updatedAt, {DateTime? deletedAt}) =>
          SyncChange(
            entityType: 'bed',
            entityId: 'pot1',
            payload: {
              'id': 'pot1',
              'name': 'v${updatedAt.month}',
              'kind': 'bucket',
              'createdAt': DateTime(2026, 1, 1).toIso8601String(),
            },
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: 'device-2',
            rev: 1,
          );

      await adapter.applyRemoteChange(potChange(DateTime(2026, 3, 1)));
      await adapter.applyRemoteChange(potChange(DateTime(2026, 2, 1)));
      final pot = (await db.potsDao.getById('pot1'))!;
      expect(pot.name, 'v3');
      // Unknown kinds from a newer client read as other.
      expect(pot.kind, PotKind.other);
      expect(pot.material, isNull);

      await adapter.applyRemoteChange(potChange(DateTime(2026, 4, 1),
          deletedAt: DateTime(2026, 4, 1)));
      expect((await db.potsDao.getById('pot1'))!.deletedAt, isNotNull);
      expect(await db.potsDao.getAll(), isEmpty);
    });
  });

  test('reminders round-trip through localChangesSince/applyRemoteChange',
      () async {
    await db.remindersDao.upsert(RemindersTableCompanion.insert(
      id: 'rem1',
      plantId: 'plant1',
      entryType: EntryType.pruning,
      intervalDays: 90,
      enabled: const Value(false),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 2, 1),
      localRev: const Value(4),
    ));

    final change = (await adapter.localChangesSince(0,
            limit: 100, deviceId: 'device-1'))
        .single;
    expect(change.entityType, 'reminder');
    expect(change.payload['entryType'], 'pruning');

    // Through the wire format into a second device.
    final other = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(other.close);
    await DriftSyncStorageAdapter(other)
        .applyRemoteChange(SyncChange.fromJson(change.toJson()));

    final applied = await other.remindersDao.getById('rem1');
    expect(applied, isNotNull);
    expect(applied!.plantId, 'plant1');
    expect(applied.entryType, EntryType.pruning);
    expect(applied.intervalDays, 90);
    expect(applied.enabled, isFalse);
    expect(applied.createdAt, DateTime(2026, 1, 1));
    expect(applied.updatedAt, DateTime(2026, 2, 1));
    // Freshly-arrived remote data is already in sync with the peer.
    expect(applied.localRev, 0);
  });

  test('a reminder for an unknown entry type is skipped', () async {
    await adapter.applyRemoteChange(SyncChange(
      entityType: 'reminder',
      entityId: 'rem1',
      payload: {
        'id': 'rem1',
        'plantId': 'plant1',
        'entryType': 'grafting',
        'intervalDays': 365,
        'enabled': true,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      },
      updatedAt: DateTime(2026, 1, 1),
      deviceId: 'device-2',
      rev: 1,
    ));

    expect(await db.remindersDao.getById('rem1'), isNull);
  });

  group('entries', () {
    SyncChange entryChange(String id, String type, {int rev = 1}) =>
        SyncChange(
          entityType: 'entry',
          entityId: id,
          payload: {
            'id': id,
            'plantId': 'plant1',
            'date': DateTime(2026, 5, 1).toIso8601String(),
            'photoPath': null,
            'note': 'Vaso maior',
            'type': type,
            'numericValue': null,
            'extraData': '{"potDiameterCm":20.0,"potMaterial":"clay"}',
            'createdAt': DateTime(2026, 5, 1).toIso8601String(),
          },
          updatedAt: DateTime(2026, 5, 1),
          deviceId: 'device-2',
          rev: rev,
        );

    test('a repotting entry round-trips', () async {
      await adapter.applyRemoteChange(entryChange('e1', 'repotting'));
      final row = await db.entriesDao.getById('e1');
      expect(row!.type, EntryType.repotting);
      expect(row.extraData, '{"potDiameterCm":20.0,"potMaterial":"clay"}');

      await db.entriesDao.upsert(
          row.toCompanion(false).copyWith(localRev: const Value(3)));
      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload['type'], 'repotting');
    });

    test('a harvest entry round-trips', () async {
      const extra = '{"quantity":1.5,"unit":"kg","duringCarencia":true}';
      await adapter.applyRemoteChange(SyncChange(
        entityType: 'entry',
        entityId: 'e1',
        payload: {
          ...entryChange('e1', 'harvest').payload,
          'extraData': extra,
        },
        updatedAt: DateTime(2026, 5, 1),
        deviceId: 'device-2',
        rev: 1,
      ));
      final row = await db.entriesDao.getById('e1');
      expect(row!.type, EntryType.harvest);
      expect(row.extraData, extra);

      await db.entriesDao.upsert(
          row.toCompanion(false).copyWith(localRev: const Value(3)));
      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload['type'], 'harvest');
      expect(change.payload['extraData'], extra);
    });

    test('an entry of an unknown type is skipped without failing the pull',
        () async {
      await adapter.applyRemoteChange(entryChange('e1', 'grafting'));
      await adapter.applyRemoteChange(entryChange('e2', 'observation', rev: 2));

      expect(await db.entriesDao.getById('e1'), isNull);
      expect((await db.entriesDao.getById('e2'))!.type, EntryType.observation);
    });

    test('a stored unknown type reads back as other', () async {
      await db.customStatement(
          "INSERT INTO entries (id, plant_id, date, type, created_at, "
          "updated_at) VALUES ('e1', 'plant1', 0, 'grafting', 0, 0)");
      expect((await db.entriesDao.getById('e1'))!.type, EntryType.other);
    });
  });

  group('legacy location text', () {
    SyncChange legacyPlant(String id, String? location,
            {String? locationId}) =>
        SyncChange(
          entityType: 'plant',
          entityId: id,
          payload: {
            'id': id,
            'speciesId': 'species1',
            'nickname': 'Planta',
            'soilId': 'sandy',
            'acquisitionDate': DateTime(2026, 1, 1).toIso8601String(),
            'location': location,
            'locationId': locationId,
            'createdAt': DateTime(2026, 1, 1).toIso8601String(),
          },
          updatedAt: DateTime(2026, 2, 1),
          deviceId: 'device-2',
          rev: 1,
        );

    test('is linked to one location when pulled without a locationId',
        () async {
      await adapter.applyRemoteChange(legacyPlant('plant1', 'Varanda'));
      await adapter.applyRemoteChange(legacyPlant('plant2', ' varanda'));

      final plant1 = await db.plantsDao.getById('plant1');
      final plant2 = await db.plantsDao.getById('plant2');
      expect(plant1!.locationId, isNotNull);
      expect(plant2!.locationId, plant1.locationId);
      // The plant stays as received; only the new location is pushed.
      expect(plant1.localRev, 0);

      final location = await db.locationsDao.getById(plant1.locationId!);
      expect(location!.name, 'Varanda');
      expect(location.localRev, greaterThan(0));
      expect(await db.locationsDao.getAll(), hasLength(1));
    });

    test('is ignored when the payload already has a locationId', () async {
      await adapter.applyRemoteChange(
          legacyPlant('plant1', 'Varanda', locationId: 'loc1'));

      expect((await db.plantsDao.getById('plant1'))!.locationId, 'loc1');
      expect(await db.locationsDao.getAll(), isEmpty);
    });

    test('is no longer sent in the outgoing payload', () async {
      await db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: 'plant1',
        speciesId: 'species1',
        nickname: 'Planta',
        soilType: 'sandy',
        acquisitionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        localRev: const Value(1),
      ));

      final change = (await adapter.localChangesSince(0,
              limit: 100, deviceId: 'device-1'))
          .single;
      expect(change.payload.containsKey('location'), isFalse);
      expect(change.payload.containsKey('locationId'), isTrue);
    });
  });
}
