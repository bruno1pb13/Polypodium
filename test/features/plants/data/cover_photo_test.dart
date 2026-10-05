import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/domain/plant_photos.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';

class _NoopNotifications implements INotificationService {
  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {}
}

void main() {
  late AppDatabase db;
  late PlantsRepository repo;

  final t0 = DateTime(2026, 1, 1);

  Future<void> addPlant(String id) =>
      db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: id,
        speciesId: 'species1',
        nickname: 'Plant $id',
        soilType: 'loamy',
        acquisitionDate: t0,
        createdAt: t0,
        updatedAt: t0,
      ));

  Future<void> addEntry(String id, String plantId, int day,
          {String? photoPath, DateTime? deletedAt}) =>
      db.entriesDao.upsert(EntriesTableCompanion.insert(
        id: id,
        plantId: plantId,
        date: DateTime(2026, 1, day),
        photoPath: Value(photoPath),
        type: EntryType.observation,
        createdAt: t0,
        updatedAt: t0,
        deletedAt: Value(deletedAt),
      ));

  Future<String?> cover(String plantId) =>
      db.entriesDao.watchCoverPhotoPath(plantId).first;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'dev-1');
    repo = PlantsRepository(db, _NoopNotifications());
    await addPlant('p1');
    await addPlant('p2');
    await addEntry('old', 'p1', 1, photoPath: '/photos/old.jpg');
    await addEntry('new', 'p1', 5, photoPath: '/photos/new.jpg');
    await addEntry('nophoto', 'p1', 9);
    await addEntry('other', 'p2', 3, photoPath: '/photos/other.jpg');
  });

  tearDown(() async => db.close());

  test('without a pick the latest photo is the cover', () async {
    expect(await cover('p1'), '/photos/new.jpg');
    expect(await cover('missing'), isNull);
  });

  test('the picked photo is the cover and is a synced local write', () async {
    await repo.setCoverPhoto('p1', 'old');

    expect(await cover('p1'), '/photos/old.jpg');
    final row = await db.plantsDao.getById('p1');
    expect(row!.coverPhotoId, 'old');
    expect(row.localRev, greaterThan(0));
    expect(row.deviceId, 'dev-1');

    await repo.setCoverPhoto('p1', null);
    expect(await cover('p1'), '/photos/new.jpg');
  });

  test('falls back to the latest photo when the pick is gone', () async {
    await repo.setCoverPhoto('p1', 'old');
    await addEntry('old', 'p1', 1,
        photoPath: '/photos/old.jpg', deletedAt: DateTime(2026, 2, 1));
    expect(await cover('p1'), '/photos/new.jpg');

    // Not a photo of this plant, or not a photo at all.
    await repo.setCoverPhoto('p1', 'other');
    expect(await cover('p1'), '/photos/new.jpg');
    await repo.setCoverPhoto('p1', 'nophoto');
    expect(await cover('p1'), '/photos/new.jpg');
  });

  test('the cover stream follows new photos and picks', () async {
    final seen = <String?>[];
    final sub = db.entriesDao.watchCoverPhotoPath('p1').listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await addEntry('newest', 'p1', 20, photoPath: '/photos/newest.jpg');
    await pumpEventQueue();
    await repo.setCoverPhoto('p1', 'old');
    await pumpEventQueue();

    expect(seen, ['/photos/new.jpg', '/photos/newest.jpg', '/photos/old.jpg']);
  });

  group('coverPhotoIdOf', () {
    EntryModel entry(String id, int day, String? photo) => EntryModel(
          id: id,
          plantId: 'p1',
          date: DateTime(2026, 1, day),
          photoPath: photo,
          type: EntryType.observation,
          createdAt: t0,
        );

    final photos = plantPhotosOf([
      entry('b', 5, '/b.jpg'),
      entry('a', 1, '/a.jpg'),
      entry('c', 9, null),
    ]);

    test('lists the photos oldest first', () {
      expect(photos.map((p) => p.photo.id), ['a', 'b']);
    });

    test('keeps a pick that is still there, else the latest', () {
      expect(coverPhotoIdOf(photos, 'a'), 'a');
      expect(coverPhotoIdOf(photos, null), 'b');
      expect(coverPhotoIdOf(photos, 'gone'), 'b');
      expect(coverPhotoIdOf(const [], 'a'), isNull);
    });
  });
}
