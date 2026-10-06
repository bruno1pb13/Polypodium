import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';

class _NoPhotos implements PhotoStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The cross-plant queries behind the dashboard and the activity screen.
void main() {
  late AppDatabase db;
  late EntriesRepository repo;

  EntryModel entry(String id, String plantId, int day,
          {EntryType type = EntryType.irrigation}) =>
      EntryModel(
        id: id,
        plantId: plantId,
        date: DateTime(2026, 1, day, 10),
        type: type,
        createdAt: DateTime(2026, 1, day),
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'dev-1');
    repo = EntriesRepository(db, _NoPhotos());
    for (final plantId in ['p1', 'p2']) {
      await db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: plantId,
        speciesId: 'species1',
        nickname: plantId,
        soilType: 'loamy',
        acquisitionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));
    }
    await repo.create(entry('old', 'p1', 2));
    await repo.create(entry('a', 'p1', 10));
    await repo.create(entry('b', 'p2', 12, type: EntryType.pest));
    await repo.create(entry('gone', 'p2', 11));
    await repo.delete('gone');
  });

  tearDown(() async => db.close());

  test('watchSince lists every plant\'s entries since the day, newest first',
      () async {
    final entries = await repo.watchSince(DateTime(2026, 1, 5)).first;
    expect(entries.map((e) => e.id), ['b', 'a']);
  });

  test('watchDatesSince returns just plant and date of each entry', () async {
    final dates = await repo.watchDatesSince(DateTime(2026, 1, 5)).first;
    expect(
      dates,
      unorderedEquals([
        (plantId: 'p1', date: DateTime(2026, 1, 10, 10)),
        (plantId: 'p2', date: DateTime(2026, 1, 12, 10)),
      ]),
    );
  });

  test('watchOfTypes filters by entry type', () async {
    final entries = await repo.watchOfTypes([EntryType.pest]).first;
    expect(entries.map((e) => e.id), ['b']);
  });
}
