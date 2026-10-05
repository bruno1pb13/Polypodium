import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/data/reminders_repository.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';

class RecordingNotificationService implements INotificationService {
  List<PlantWithSpecies>? lastScheduled;
  List<PlantReminder>? lastReminders;

  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {
    lastScheduled = plants;
    lastReminders = reminders;
  }
}

void main() {
  late AppDatabase db;
  late RecordingNotificationService notifications;
  late PlantsRepository repo;

  final t0 = DateTime(2026, 1, 1);

  PlantModel plant(String id,
          {PlantStatus status = PlantStatus.active,
          DateTime? statusChangedAt}) =>
      PlantModel(
        id: id,
        speciesId: 'species1',
        nickname: 'Plant $id',
        soilId: 'loamy',
        acquisitionDate: t0,
        createdAt: t0,
        status: status,
        statusChangedAt: statusChangedAt,
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    notifications = RecordingNotificationService();
    repo = PlantsRepository(db, notifications);
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: 'Ficus lyrata',
      popularName: 'Ficus',
      defaultIrrigationFrequencyDays: const Value(3),
      recommendedSoilTypes: const [],
      createdAt: t0,
      updatedAt: t0,
    ));
  });

  tearDown(() async => db.close());

  test('status and statusChangedAt round-trip through the repository',
      () async {
    final changedAt = DateTime(2026, 3, 4, 5, 6);
    await repo.save(
        plant('p1', status: PlantStatus.donated, statusChangedAt: changedAt));

    final loaded = await repo.getById('p1');
    expect(loaded!.status, PlantStatus.donated);
    expect(loaded.statusChangedAt, changedAt);
    expect(loaded.isActive, isFalse);
  });

  test('new plants default to active', () async {
    await repo.save(plant('p1'));

    final loaded = await repo.getById('p1');
    expect(loaded!.status, PlantStatus.active);
    expect(loaded.statusChangedAt, isNull);
  });

  test('rescheduleNotifications only schedules active plants', () async {
    await repo.save(plant('alive'));
    await repo.save(plant('dead', status: PlantStatus.dead));
    await repo.save(plant('donated', status: PlantStatus.donated));
    await repo.save(plant('archived', status: PlantStatus.archived));

    await repo.rescheduleNotifications();

    expect(notifications.lastScheduled!.map((p) => p.plant.id), ['alive']);
  });

  test('archived plants stay listed (not deleted) with their diary', () async {
    await repo.save(plant('p1', status: PlantStatus.archived));
    await db.entriesDao.insert(EntriesTableCompanion.insert(
      id: 'e1',
      plantId: 'p1',
      date: t0,
      type: EntryType.observation,
      createdAt: t0,
      updatedAt: t0,
    ));

    expect((await repo.getAll()).map((p) => p.id), ['p1']);
    expect((await db.entriesDao.getById('e1'))!.deletedAt, isNull);
  });

  test('rescheduleNotifications passes enabled reminders of active plants',
      () async {
    await repo.save(plant('alive'));
    await repo.save(plant('archived', status: PlantStatus.archived));
    final reminders = RemindersRepository(db);
    for (final (id, plantId, enabled) in [
      ('r-alive', 'alive', true),
      ('r-paused', 'alive', false),
      ('r-archived', 'archived', true),
    ]) {
      await reminders.save(ReminderModel(
        id: id,
        plantId: plantId,
        entryType: EntryType.fertilizer,
        intervalDays: 30,
        enabled: enabled,
        createdAt: t0,
      ));
    }

    await repo.rescheduleNotifications();

    final scheduled = notifications.lastReminders!;
    expect(scheduled.map((r) => r.status.reminder.id), ['r-alive']);
    expect(scheduled.single.plant.nickname, 'Plant alive');
  });

  test('deleting a plant tombstones its reminders', () async {
    await repo.save(plant('p1'));
    final reminders = RemindersRepository(db);
    await reminders.save(ReminderModel(
      id: 'r1',
      plantId: 'p1',
      entryType: EntryType.pruning,
      intervalDays: 90,
      createdAt: t0,
    ));

    await repo.delete('p1');

    expect((await reminders.getById('r1'))!.deletedAt, isNotNull);
    expect(notifications.lastReminders, isEmpty);
  });

  group('refreshPesticideStatus', () {
    Future<void> pesticideEntry(String id, DateTime date, String? extraData) =>
        db.entriesDao.insert(EntriesTableCompanion.insert(
          id: id,
          plantId: 'p1',
          date: date,
          type: EntryType.pesticide,
          extraData: Value(extraData),
          createdAt: date,
          updatedAt: date,
        ));

    test('tracks recurrenceDays of the latest application', () async {
      await repo.save(plant('p1'));
      final applied = DateTime(2026, 2, 1);
      await pesticideEntry(
          'e1',
          applied,
          '{"products":[{"defensivoId":"d1","name":"Neem","dose":"5 ml/L"}],'
              '"recurrenceDays":14}');

      await repo.refreshPesticideStatus('p1');

      final loaded = await repo.getById('p1');
      expect(loaded!.lastPesticideAppliedAt, applied);
      expect(loaded.pesticideReapplicationDays, 14);
    });

    test('a newer application without recurrence clears the reminder',
        () async {
      await repo.save(plant('p1'));
      await pesticideEntry('e1', DateTime(2026, 2, 1), '{"recurrenceDays":7}');
      final latest = DateTime(2026, 2, 10);
      await pesticideEntry('e2', latest,
          '{"products":[{"defensivoId":"d1","name":"Neem"}]}');

      await repo.refreshPesticideStatus('p1');

      final loaded = await repo.getById('p1');
      expect(loaded!.lastPesticideAppliedAt, latest);
      expect(loaded.pesticideReapplicationDays, isNull);
    });
  });
}
