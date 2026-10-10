import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/database/database_provider.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/l10n/l10n.dart';
import 'package:polypodium/core/notifications/notification_provider.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/storage/photo_storage_provider.dart';
import 'package:polypodium/features/entries/domain/entry_details.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/pots/domain/pot_model.dart';
import 'package:polypodium/features/pots/presentation/providers/pots_providers.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';

class _NoopNotificationService implements INotificationService {
  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {}
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  final t0 = DateTime(2024, 1, 1);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'dev-a');
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 's1',
      scientificName: 'Polypodium vulgare',
      popularName: 'Samambaia',
      recommendedSoilTypes: const [],
      createdAt: t0,
      updatedAt: t0,
    ));
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(_NoopNotificationService()),
      photoStorageProvider
          .overrideWithValue(PhotoStorage(baseDirName: 'test_photos')),
    ]);
    for (final id in ['p1', 'p2']) {
      await container.read(plantsRepositoryProvider).save(PlantModel(
            id: id,
            speciesId: 's1',
            nickname: 'Ferny $id',
            soilId: 'loamy',
            acquisitionDate: t0,
            createdAt: t0,
          ));
    }
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  EntryModel repotting(String plantId, RepottingDetails details) => EntryModel(
        id: 'e-$plantId',
        plantId: plantId,
        date: DateTime(2026, 5, 1),
        type: EntryType.repotting,
        extraData: details.encode(),
        createdAt: DateTime(2026, 5, 1),
      );

  Future<List<EntryModel>> entriesOf(String plantId) =>
      container.read(entriesRepositoryProvider).getByPlant(plantId);

  test('a repotting with a new soil moves the plant and logs it in history',
      () async {
    final l10n = systemL10n();
    final revBefore =
        (await container.read(plantsRepositoryProvider).getById('p1'))!;

    await container.read(entryMutationsProvider).createMany([
      for (final id in ['p1', 'p2'])
        repotting(
            id,
            RepottingDetails(
              potDiameterCm: 20,
              newSoilId: SoilType.succulentMix.name,
              newSoilName: SoilType.succulentMix.label(l10n),
            )),
    ]);

    for (final id in ['p1', 'p2']) {
      final plant =
          (await container.read(plantsRepositoryProvider).getById(id))!;
      expect(plant.soilId, SoilType.succulentMix.name);
      final entries = await entriesOf(id);
      expect(entries.map((e) => e.type),
          containsAll([EntryType.repotting, EntryType.history]));
      final history = entries.singleWhere((e) => e.type == EntryType.history);
      expect(
        history.note,
        '${l10n.historyUpdatedHeader}\n• ${l10n.historyFieldSoil}: '
        '${SoilType.loamy.label(l10n)} → ${SoilType.succulentMix.label(l10n)}',
      );
    }
    // A regular local write: new rev, stamped with this device.
    final row = (await db.plantsDao.getById('p1'))!;
    expect(row.localRev, greaterThan(revBefore.localRev));
    expect(row.deviceId, 'dev-a');
  });

  test('a repotting without a new soil, or with the same soil, keeps the plant',
      () async {
    await container.read(entryMutationsProvider).createMany([
      repotting('p1', const RepottingDetails(potMaterial: PotMaterial.clay)),
      repotting('p2', const RepottingDetails(newSoilId: 'loamy')),
    ]);

    for (final id in ['p1', 'p2']) {
      final plant =
          (await container.read(plantsRepositoryProvider).getById(id))!;
      expect(plant.soilId, 'loamy');
      expect((await entriesOf(id)).map((e) => e.type), [EntryType.repotting]);
    }
  });

  group('pots', () {
    Future<void> addPot(String id, {String? locationId}) =>
        container.read(potsRepositoryProvider).save(PotModel(
              id: id,
              name: 'Vaso $id',
              diameterCm: 30,
              locationId: locationId,
              createdAt: t0,
            ));

    test('a repotting into a pot moves every plant there, noting where '
        'each one came from, without a second entry', () async {
      await addPot('old');
      await addPot('big', locationId: 'balcony');
      await container.read(potsRepositoryProvider)
          .movePlantToPot('p1', 'old', recordEntry: false);

      await container.read(entryMutationsProvider).createMany([
        for (final id in ['p1', 'p2'])
          repotting(id,
              const RepottingDetails(toPotId: 'big', toPotName: 'Vaso big')),
      ]);

      for (final id in ['p1', 'p2']) {
        final plant =
            (await container.read(plantsRepositoryProvider).getById(id))!;
        expect(plant.potId, 'big');
        expect(plant.locationId, 'balcony');
        expect((await entriesOf(id)).map((e) => e.type),
            [EntryType.repotting]);
      }
      final p1Details =
          (await entriesOf('p1')).single.details as RepottingDetails;
      expect(p1Details.fromPotId, 'old');
      final p2Details =
          (await entriesOf('p2')).single.details as RepottingDetails;
      expect(p2Details.fromPotId, isNull);
    });

    test('changing the pot on the plant form records the move, keeping the '
        'location picked on the form', () async {
      await addPot('big', locationId: 'balcony');
      final plant =
          (await container.read(plantsRepositoryProvider).getById('p1'))!;

      await container
          .read(plantMutationsProvider)
          .save(plant.copyWith(potId: 'big', locationId: 'kitchen'));

      final saved =
          (await container.read(plantsRepositoryProvider).getById('p1'))!;
      expect(saved.potId, 'big');
      expect(saved.locationId, 'kitchen');
      final entries = await entriesOf('p1');
      final move = entries.singleWhere((e) => e.type == EntryType.repotting);
      expect((move.details as RepottingDetails).toPotId, 'big');
    });
  });
}
