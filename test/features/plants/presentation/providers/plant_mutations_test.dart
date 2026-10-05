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
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';

class _NoopNotificationService implements INotificationService {
  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {}
}

/// Saving goes through the keepAlive [PlantMutations], so it must not depend
/// on anything keeping the autoDispose plants/species/locations/soils
/// notifiers alive (e.g. the add/edit screen opened over a route that doesn't
/// watch the plants).
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  final t0 = DateTime(2024, 1, 1);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 's1',
      scientificName: 'Polypodium vulgare',
      popularName: 'Samambaia',
      recommendedSoilTypes: const [],
      createdAt: t0,
      updatedAt: t0,
    ));
    await db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: 'l1',
      name: 'Varanda',
      createdAt: t0,
      updatedAt: t0,
    ));
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(_NoopNotificationService()),
      photoStorageProvider
          .overrideWithValue(PhotoStorage(baseDirName: 'test_photos')),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  final plant = PlantModel(
    id: 'p1',
    speciesId: 's1',
    nickname: 'Ferny',
    soilId: 'loamy',
    acquisitionDate: t0,
    createdAt: t0,
  );

  Future<PlantModel?> stored() =>
      container.read(plantsRepositoryProvider).getById('p1');

  Future<List<String?>> historyNotes() async => [
        for (final e
            in await container.read(entriesRepositoryProvider).getByPlant('p1'))
          if (e.type == EntryType.history) e.note,
      ];

  test('save, edit and setStatus complete with nothing listening', () async {
    final l10n = systemL10n();
    final notifier = container.read(plantsNotifierProvider.notifier);

    await notifier.save(plant);
    expect((await stored())?.nickname, 'Ferny');
    final creation = (await historyNotes()).single!;
    expect(creation, startsWith(l10n.historyPlantAdded));
    expect(creation, contains('Samambaia (Polypodium vulgare)'));

    await container
        .read(plantsNotifierProvider.notifier)
        .save(plant.copyWith(nickname: 'Ferny 2', locationId: 'l1'));
    expect((await stored())?.nickname, 'Ferny 2');
    expect(
      await historyNotes(),
      contains('${l10n.historyUpdatedHeader}\n'
          '• ${l10n.historyFieldNickname}: Ferny → Ferny 2\n'
          '• ${l10n.historyFieldLocation}: ${l10n.none} → Varanda'),
    );

    await container
        .read(plantsNotifierProvider.notifier)
        .setStatus('p1', PlantStatus.dead);
    final row = await stored();
    expect(row?.status, PlantStatus.dead);
    expect(row?.statusChangedAt, isNotNull);
    expect(await historyNotes(), hasLength(3));
  });
}
