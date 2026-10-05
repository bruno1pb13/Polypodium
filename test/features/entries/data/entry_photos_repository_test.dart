import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';

class _RecordingPhotoStorage implements PhotoStorage {
  final deleted = <String>[];
  List<String>? referenced;

  @override
  String get baseDirName => 'plant_photos';

  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async =>
      referenced = referencedPaths;

  @override
  Future<void> deletePhoto(String path) async => deleted.add(path);

  @override
  Future<String> savePhoto(dynamic file) async => '';

  @override
  Future<String> savePhotoBytes(List<int> bytes, String fileName) async => '';

  @override
  Future<String> restorePhoto(List<int> bytes, String fileName) async => '';
}

class _NoopNotifications implements INotificationService {
  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {}
}

void main() {
  late AppDatabase db;
  late _RecordingPhotoStorage photos;
  late EntriesRepository repo;

  EntryModel entry(String id, int day, {List<String> photoPaths = const []}) =>
      EntryModel(
        id: id,
        plantId: 'p1',
        date: DateTime(2026, 1, day),
        type: EntryType.observation,
        photoPath: photoPaths.firstOrNull,
        extraPhotos: [
          for (final (i, path) in photoPaths.skip(1).indexed)
            EntryPhoto(id: '$id-ph${i + 2}', path: path),
        ],
        createdAt: DateTime(2026, 1, day),
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'dev-1');
    photos = _RecordingPhotoStorage();
    repo = EntriesRepository(db, photos);
    await db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'p1',
      speciesId: 'species1',
      nickname: 'Planta',
      soilType: 'loamy',
      acquisitionDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ));
  });

  tearDown(() async => db.close());

  test('an entry keeps its first photo on the entry and the rest in order',
      () async {
    await repo.create(entry('e1', 1, photoPaths: ['/a', '/b', '/c']));

    final row = await db.entriesDao.getById('e1');
    expect(row!.photoPath, '/a');
    final extra = await db.entryPhotosDao.getByEntries(['e1']);
    expect(extra.map((r) => (r.id, r.photoPath, r.position)), [
      ('e1-ph2', '/b', 1),
      ('e1-ph3', '/c', 2),
    ]);
    // Synced rows written after the entry, stamped by this device.
    expect(extra.every((r) => r.localRev > row.localRev), isTrue);
    expect(extra.every((r) => r.deviceId == 'dev-1'), isTrue);

    final read = await repo.getById('e1');
    expect(read!.photos.map((p) => p.path), ['/a', '/b', '/c']);
    expect((await repo.getByPlant('p1')).single.photos.map((p) => p.id),
        ['e1', 'e1-ph2', 'e1-ph3']);
  });

  test('watchByPlant follows photos arriving after their entry', () async {
    await repo.create(entry('e1', 1, photoPaths: ['/a']));
    await repo.create(entry('e2', 2));
    final seen = <List<List<String>>>[];
    final sub = repo.watchByPlant('p1').listen((list) =>
        seen.add([for (final e in list) e.photos.map((p) => p.path).toList()]));
    addTearDown(sub.cancel);
    await pumpEventQueue();

    // As a pulled entry_photo row lands.
    await db.entryPhotosDao.upsert(EntryPhotosTableCompanion.insert(
      id: 'remote',
      entryId: 'e1',
      photoPath: '/r',
      position: const Value(1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ));
    await pumpEventQueue();

    expect(seen.first, [
      <String>[],
      ['/a']
    ]);
    expect(seen.last, [
      <String>[],
      ['/a', '/r']
    ]);
  });

  test('deleting an entry deletes its photo rows and files', () async {
    await repo.create(entry('e1', 1, photoPaths: ['/a', '/b', '/c']));

    await repo.delete('e1');

    expect(photos.deleted, ['/a', '/b', '/c']);
    expect(await db.entryPhotosDao.getByEntries(['e1']), isEmpty);
    final tombstone = await db.entryPhotosDao.getById('e1-ph2');
    expect(tombstone!.deletedAt, isNotNull);
    expect(tombstone.localRev, greaterThan(0));
  });

  test('the retention policy deletes the photos of dropped entries', () async {
    await repo.create(entry('old', 1, photoPaths: ['/old1', '/old2']));
    for (var day = 2; day <= 31; day++) {
      await repo.create(entry('e$day', day));
    }
    await repo.create(entry('new', 32, photoPaths: ['/new1', '/new2']));

    expect(photos.deleted, ['/old1', '/old2']);
    expect((await db.entryPhotosDao.getById('old-ph2'))!.deletedAt, isNotNull);
    // Orphan cleanup keeps every live photo, extra ones included.
    expect(photos.referenced, unorderedEquals(['/new1', '/new2']));
  });

  test(
      'deleting a plant deletes its entries\' photo rows and returns their '
      'files', () async {
    await repo.create(entry('e1', 1, photoPaths: ['/a', '/b']));
    await repo.create(entry('e2', 2, photoPaths: ['/c']));

    final paths = await PlantsRepository(db, _NoopNotifications()).delete('p1');

    expect(paths, unorderedEquals(['/a', '/b', '/c']));
    expect((await db.entryPhotosDao.getById('e1-ph2'))!.deletedAt, isNotNull);
  });

  test('an entry photo picked as cover is the plant cover', () async {
    await repo.create(entry('e1', 1, photoPaths: ['/a', '/b']));
    await repo.create(entry('e2', 2, photoPaths: ['/c']));
    final plants = PlantsRepository(db, _NoopNotifications());
    Future<String?> cover() => db.entriesDao.watchCoverPhotoPath('p1').first;

    expect(await cover(), '/c');
    await plants.setCoverPhoto('p1', 'e1-ph2');
    expect(await cover(), '/b');

    await repo.delete('e1');
    expect(await cover(), '/c');
  });
}
