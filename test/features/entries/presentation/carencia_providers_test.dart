import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/database/database_provider.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/storage/photo_storage_provider.dart';
import 'package:polypodium/features/defensivos/domain/defensivo_model.dart';
import 'package:polypodium/features/defensivos/presentation/providers/defensivos_providers.dart';
import 'package:polypodium/features/entries/domain/carencia.dart';
import 'package:polypodium/features/entries/domain/entry_details.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/carencia_providers.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  final t0 = DateTime(2024, 1, 1);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

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
      photoStorageProvider
          .overrideWithValue(PhotoStorage(baseDirName: 'test_photos')),
    ]);
    for (final id in ['p1', 'p2']) {
      await container.read(plantsRepositoryProvider).save(PlantModel(
            id: id,
            speciesId: 's1',
            nickname: 'Horta $id',
            soilId: 'loamy',
            acquisitionDate: t0,
            createdAt: t0,
          ));
    }
    await container.read(defensivosRepositoryProvider).save(
        DefensivoModel(id: 'd1', name: 'Neem', carenciaDays: 3, createdAt: t0));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> addPesticide(String plantId, DateTime date, {int? copiedDays}) =>
      container.read(entriesRepositoryProvider).create(EntryModel(
            id: 'e-$plantId-${date.millisecondsSinceEpoch}',
            plantId: plantId,
            date: date,
            type: EntryType.pesticide,
            extraData: PesticideDetails(products: [
              PesticideProduct(
                  defensivoId: 'd1', name: 'Neem', carenciaDays: copiedDays),
            ]).encode(),
            createdAt: date,
          ));

  /// Keeps the autoDispose provider alive and waits for the next values.
  Future<CarenciaStatus?> settle(String plantId) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return container.read(plantCarenciaProvider(plantId));
  }

  test('follows the entries and the catalog as they change', () async {
    final sub = container.listen(plantCarenciaProvider('p1'), (_, __) {});
    addTearDown(sub.close);
    expect(await settle('p1'), isNull);

    // An older entry without a copied carência uses the catalog.
    await addPesticide('p1', now);
    expect(
        await settle('p1'),
        CarenciaStatus(
            until: DateTime(today.year, today.month, today.day + 2),
            productNames: const ['Neem']));

    await container.read(defensivosRepositoryProvider).save(DefensivoModel(
        id: 'd1', name: 'Neem', carenciaDays: 10, createdAt: t0));
    expect((await settle('p1'))?.until,
        DateTime(today.year, today.month, today.day + 9));

    await container.read(defensivosRepositoryProvider).delete('d1');
    expect(await settle('p1'), isNull);
  });

  test('the checker lists the plants in carência with their names', () async {
    await addPesticide('p2', now.subtract(const Duration(days: 1)),
        copiedDays: 5);
    await addPesticide('p1', now.subtract(const Duration(days: 4)));

    final result = await container
        .read(carenciaCheckerProvider)
        .plantsInCarencia(['p1', 'p2'], now);
    expect(result, hasLength(1));
    expect(result.single.plantId, 'p2');
    expect(result.single.plantName, 'Horta p2');
    expect(result.single.status.productNames, ['Neem']);
    expect(result.single.status.until,
        DateTime(today.year, today.month, today.day + 3));
  });
}
