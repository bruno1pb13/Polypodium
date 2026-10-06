import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/reminders/data/reminders_repository.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';

class FakePhotoStorage implements PhotoStorage {
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
  late RemindersRepository repo;
  late EntriesRepository entries;

  final t0 = DateTime(2026, 1, 1, 10);

  ReminderModel reminder(String id,
          {EntryType type = EntryType.fertilizer,
          int intervalDays = 30,
          String plantId = 'plant1'}) =>
      ReminderModel(
        id: id,
        plantId: plantId,
        entryType: type,
        intervalDays: intervalDays,
        createdAt: t0,
      );

  Future<void> addEntry(String id, EntryType type, DateTime date,
          {String plantId = 'plant1'}) =>
      entries.create(EntryModel(
        id: id,
        plantId: plantId,
        date: date,
        type: type,
        createdAt: date,
      ));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = RemindersRepository(db);
    entries = EntriesRepository(db, FakePhotoStorage());
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: 'Ficus lyrata',
      popularName: 'Ficus',
      recommendedSoilTypes: const [],
      createdAt: t0,
      updatedAt: t0,
    ));
    for (final id in ['plant1', 'plant2']) {
      await db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: id,
        speciesId: 'species1',
        nickname: 'Plant $id',
        soilType: 'loamy',
        acquisitionDate: t0,
        createdAt: t0,
        updatedAt: t0,
      ));
    }
  });

  tearDown(() async => db.close());

  test('save, edit and delete', () async {
    await repo.save(reminder('r1'));
    var saved = await repo.getById('r1');
    expect(saved?.intervalDays, 30);
    expect(saved?.enabled, isTrue);
    expect(saved!.localRev, greaterThan(0));

    await repo.save(saved.copyWith(intervalDays: 15, enabled: false));
    saved = await repo.getById('r1');
    expect(saved?.intervalDays, 15);
    expect(saved?.enabled, isFalse);

    await repo.delete('r1');
    // Tombstoned for sync, gone for the UI and the schedule.
    expect((await repo.getById('r1'))?.deletedAt, isNotNull);
    expect(await repo.getAllStatuses(), isEmpty);
  });

  test('due date counts from creation when the care was never recorded',
      () async {
    await repo.save(reminder('r1', intervalDays: 10));

    final status = (await repo.getAllStatuses()).single;
    expect(status.lastDoneAt, isNull);
    expect(status.dueDate, DateTime(2026, 1, 11));
    expect(status.daysRelative(DateTime(2026, 1, 9)), -2);
    expect(status.isDue(DateTime(2026, 1, 11, 8)), isTrue);
  });

  test('due date derives from the latest non-deleted entry of the type',
      () async {
    await repo.save(reminder('r1', intervalDays: 30));
    await addEntry('e1', EntryType.fertilizer, DateTime(2026, 2, 1));
    await addEntry('e2', EntryType.fertilizer, DateTime(2026, 3, 1, 18));
    // Other types, and other plants, don't count.
    await addEntry('e3', EntryType.pruning, DateTime(2026, 4, 1));
    await addEntry('e4', EntryType.fertilizer, DateTime(2026, 5, 1),
        plantId: 'plant2');

    var status = (await repo.getAllStatuses()).single;
    expect(status.lastDoneAt, DateTime(2026, 3, 1, 18));
    expect(status.dueDate, DateTime(2026, 3, 31));
    expect(status.daysRelative(DateTime(2026, 4, 3)), 3);

    await entries.delete('e2');
    status = (await repo.getAllStatuses()).single;
    expect(status.lastDoneAt, DateTime(2026, 2, 1));
  });

  test('the plant stream re-emits when an entry moves the due date', () async {
    await repo.save(reminder('r1'));
    await repo.save(reminder('r2', plantId: 'plant2'));

    final emissions = <List<ReminderStatus>>[];
    final sub = repo.watchStatusesByPlant('plant1').listen(emissions.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(emissions.last.map((s) => s.reminder.id), ['r1']);
    expect(emissions.last.single.lastDoneAt, isNull);

    await addEntry('e1', EntryType.fertilizer, DateTime(2026, 2, 1));
    await pumpEventQueue();
    expect(emissions.last.single.lastDoneAt, DateTime(2026, 2, 1));
  });

  test('retention keeps the latest entry a reminder derives from', () async {
    await addEntry('fert', EntryType.fertilizer, DateTime(2026, 1, 2));
    await addEntry('repot', EntryType.repotting, DateTime(2026, 1, 3));
    for (var i = 0; i < 31; i++) {
      await addEntry('obs$i', EntryType.height, DateTime(2026, 2, 1 + i));
    }

    expect((await db.entriesDao.getById('fert'))?.deletedAt, isNull);
    expect((await db.entriesDao.getById('repot'))?.deletedAt, isNull);
    // The oldest non-protected entry was purged instead.
    expect((await db.entriesDao.getById('obs0'))?.deletedAt, isNotNull);
  });

  group('setInterval', () {
    test('creates the reminder when the plant has none of the type',
        () async {
      expect(await repo.setInterval('plant1', EntryType.pruning, 45), isTrue);

      final status = (await repo.getAllStatuses()).single;
      expect(status.reminder.plantId, 'plant1');
      expect(status.reminder.entryType, EntryType.pruning);
      expect(status.reminder.intervalDays, 45);
      expect(status.reminder.enabled, isTrue);
    });

    test('updates and re-enables the existing one', () async {
      await repo.save(reminder('r1', intervalDays: 30));
      await repo.save((await repo.getById('r1'))!.copyWith(enabled: false));

      expect(
          await repo.setInterval('plant1', EntryType.fertilizer, 15), isTrue);

      final saved = (await repo.getAllStatuses()).single.reminder;
      expect(saved.id, 'r1');
      expect(saved.intervalDays, 15);
      expect(saved.enabled, isTrue);
    });

    test('is a no-op when nothing changes', () async {
      await repo.save(reminder('r1', intervalDays: 30));
      final rev = (await repo.getById('r1'))!.localRev;

      expect(
          await repo.setInterval('plant1', EntryType.fertilizer, 30), isFalse);
      expect((await repo.getById('r1'))!.localRev, rev);
    });

    test('ignores deleted reminders and other plants', () async {
      await repo.save(reminder('r1'));
      await repo.delete('r1');
      await repo.save(reminder('r2', plantId: 'plant2'));

      await repo.setInterval('plant1', EntryType.fertilizer, 10);

      final statuses = await repo.getAllStatuses();
      expect(statuses, hasLength(2));
      final plant1 =
          statuses.singleWhere((s) => s.reminder.plantId == 'plant1').reminder;
      expect(plant1.id, isNot('r1'));
      expect(plant1.intervalDays, 10);
    });
  });
}
