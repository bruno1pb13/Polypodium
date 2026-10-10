import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_details.dart';
import 'package:polypodium/features/pots/data/pots_repository.dart';
import 'package:polypodium/features/pots/domain/pot_model.dart';

class _FakePhotoStorage implements PhotoStorage {
  @override
  String get baseDirName => 'test_photos';

  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {}

  @override
  Future<void> deletePhoto(String path) async {}

  @override
  Future<String> savePhoto(dynamic file) async => '';

  @override
  Future<String> savePhotoBytes(List<int> bytes, String fileName) async => '';

  @override
  Future<String> restorePhoto(List<int> bytes, String fileName) async => '';
}

void main() {
  late AppDatabase db;
  late EntriesRepository entries;
  late PotsRepository pots;
  final t0 = DateTime(2026, 1, 1);

  Future<void> addPlant(String id, {String? potId, String? locationId}) =>
      db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: id,
        speciesId: 'species1',
        nickname: id,
        soilType: 'loamy',
        acquisitionDate: t0,
        potId: Value(potId),
        locationId: Value(locationId),
        createdAt: t0,
        updatedAt: t0,
      ));

  Future<PotModel> addPot(String id, {String? locationId}) async {
    final pot = PotModel(
      id: id,
      name: 'Vaso $id',
      diameterCm: 25,
      material: PotMaterial.clay,
      locationId: locationId,
      createdAt: t0,
    );
    await pots.save(pot);
    return pot;
  }

  Future<PlantsTableData> plant(String id) async =>
      (await db.plantsDao.getById(id))!;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'dev');
    entries = EntriesRepository(db, _FakePhotoStorage());
    pots = PotsRepository(db, entries);
  });

  tearDown(() async => db.close());

  test('two plants can share a pot', () async {
    await addPot('pot1');
    await addPlant('a');
    await addPlant('b');

    await pots.movePlantsToPot(['a', 'b'], 'pot1');

    expect((await db.plantsDao.getByPot('pot1')).map((p) => p.id),
        ['a', 'b']);
  });

  test('moving a plant is a synced write and records a repotting entry',
      () async {
    await addPot('pot1');
    await addPot('pot2');
    await addPlant('a', potId: 'pot1');

    expect(await pots.movePlantToPot('a', 'pot2'), isTrue);

    final row = await plant('a');
    expect(row.potId, 'pot2');
    expect(row.localRev, greaterThan(0));
    expect(row.deviceId, 'dev');
    final history = await entries.getByPlant('a');
    expect(history.single.type, EntryType.repotting);
    final details = history.single.details as RepottingDetails;
    expect(details.fromPotId, 'pot1');
    expect(details.toPotId, 'pot2');
    expect(details.toPotName, 'Vaso pot2');
    expect(details.potDiameterCm, 25);
    expect(details.potMaterial, PotMaterial.clay);
  });

  test('moving into the same pot changes nothing', () async {
    await addPot('pot1');
    await addPlant('a', potId: 'pot1');

    expect(await pots.movePlantToPot('a', 'pot1'), isFalse);
    expect(await entries.getByPlant('a'), isEmpty);
  });

  test('the history entry is optional', () async {
    await addPot('pot1');
    await addPlant('a');

    await pots.movePlantToPot('a', 'pot1', recordEntry: false);

    expect((await plant('a')).potId, 'pot1');
    expect(await entries.getByPlant('a'), isEmpty);
  });

  test('taking a plant out of its pot records the removal', () async {
    await addPot('pot1');
    await addPlant('a', potId: 'pot1', locationId: 'loc1');

    await pots.movePlantToPot('a', null);

    final row = await plant('a');
    expect(row.potId, isNull);
    expect(row.locationId, 'loc1');
    final details =
        (await entries.getByPlant('a')).single.details as RepottingDetails;
    expect(details.isRemovalFromPot, isTrue);
  });

  test('a plant moved into a pot with a location goes there', () async {
    await addPot('pot1', locationId: 'balcony');
    await addPlant('a', locationId: 'kitchen');
    await addPlant('b', locationId: 'kitchen');

    await pots.movePlantToPot('a', 'pot1');
    await pots.movePlantToPot('b', 'pot1', applyPotLocation: false);

    expect((await plant('a')).locationId, 'balcony');
    expect((await plant('b')).locationId, 'kitchen');
  });

  test('a pot without a location keeps the plant where it is', () async {
    await addPot('pot1');
    await addPlant('a', locationId: 'kitchen');

    await pots.movePlantToPot('a', 'pot1');

    expect((await plant('a')).locationId, 'kitchen');
  });

  test('editing the pot location moves its live plants', () async {
    final pot = await addPot('pot1', locationId: 'kitchen');
    await addPlant('a', potId: 'pot1', locationId: 'kitchen');
    await addPlant('b', potId: 'pot1', locationId: 'elsewhere');
    await addPlant('c', locationId: 'kitchen');
    final revBefore = (await plant('a')).localRev;

    await pots.save(pot.copyWith(locationId: 'balcony'));

    expect((await plant('a')).locationId, 'balcony');
    expect((await plant('a')).localRev, greaterThan(revBefore));
    expect((await plant('b')).locationId, 'balcony');
    expect((await plant('c')).locationId, 'kitchen');
  });

  test('editing other pot fields leaves the plants alone', () async {
    final pot = await addPot('pot1', locationId: 'kitchen');
    await addPlant('a', potId: 'pot1', locationId: 'elsewhere');

    await pots.save(pot.copyWith(name: 'Outro nome'));

    expect((await plant('a')).locationId, 'elsewhere');
  });

  test('moving the pot to a location moves its plants', () async {
    await addPot('pot1');
    await addPlant('a', potId: 'pot1', locationId: 'kitchen');
    await addPlant('b', potId: 'pot1');

    await pots.moveToLocation('pot1', 'balcony');

    expect((await pots.getById('pot1'))!.locationId, 'balcony');
    expect((await plant('a')).locationId, 'balcony');
    expect((await plant('b')).locationId, 'balcony');
  });

  test('deleting a pot takes its plants out of it', () async {
    await addPot('pot1');
    await addPlant('a', potId: 'pot1');
    await addPlant('b', potId: 'pot1');
    final revBefore = (await plant('a')).localRev;

    expect(await pots.delete('pot1'), 2);

    expect((await plant('a')).potId, isNull);
    expect((await plant('a')).localRev, greaterThan(revBefore));
    expect((await plant('b')).potId, isNull);
    expect(await pots.getAll(), isEmpty);
    expect((await db.potsDao.getById('pot1'))!.deletedAt, isNotNull);
  });

  test('moving all plants to another pot', () async {
    await addPot('small');
    await addPot('big', locationId: 'garden');
    await addPlant('a', potId: 'small');
    await addPlant('b', potId: 'small');

    final moved = await pots.moveAllPlants('small', 'big');

    expect(moved, unorderedEquals(['a', 'b']));
    expect(await db.plantsDao.getByPot('small'), isEmpty);
    expect((await plant('b')).locationId, 'garden');
  });

  test('moving into a deleted pot fails without writing', () async {
    await addPot('pot1');
    await pots.delete('pot1');
    await addPlant('a');

    expect(() => pots.movePlantToPot('a', 'pot1'), throwsArgumentError);
    expect((await plant('a')).potId, isNull);
  });
}
