import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/features/data_transfer/data/data_export_service.dart';
import 'package:polypodium/features/data_transfer/data/data_import_service.dart';

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
  Future<String> restorePhoto(List<int> bytes, String fileName) async =>
      '/restored/$fileName';
}

void main() {
  late AppDatabase source;
  late AppDatabase target;

  final t0 = DateTime(2026, 1, 1);
  final t1 = DateTime(2026, 2, 1);

  Future<void> seedSpecies(AppDatabase db, String name, DateTime updatedAt,
      {DateTime? deletedAt, int rev = 1}) async {
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: name,
      popularName: 'Popular',
      recommendedSoilTypes: const ['loamy'],
      createdAt: t0,
      updatedAt: updatedAt,
      deletedAt: Value(deletedAt),
      localRev: Value(rev),
    ));
  }

  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    target = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('exported backup round-trips into an empty workspace', () async {
    await seedSpecies(source, 'Ficus lyrata', t0);
    await source.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Minha planta',
      soilType: 'loamy',
      acquisitionDate: t0,
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(2),
    ));
    await source.entriesDao.insert(EntriesTableCompanion.insert(
      id: 'entry1',
      plantId: 'plant1',
      date: t0,
      type: EntryType.irrigation,
      createdAt: t0,
      updatedAt: t0,
      localRev: const Value(3),
    ));

    final bytes = await DataExportService(source).buildArchiveBytes();
    final summary = await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final species = await target.speciesDao.getById('species1');
    final plant = await target.plantsDao.getById('plant1');
    final entry = await target.entriesDao.getById('entry1');

    expect(species?.scientificName, 'Ficus lyrata');
    expect(plant?.nickname, 'Minha planta');
    expect(entry?.type, EntryType.irrigation);
    // Every applied row must carry a fresh localRev so it gets pushed to the
    // server on the next sync.
    expect(species!.localRev, greaterThan(0));
    expect(summary.applied, greaterThanOrEqualTo(3));

    // Imported irrigation entries recompute the derived lastIrrigatedAt.
    expect(plant!.lastIrrigatedAt, t0);
  });

  test('importing an older backup row never overwrites newer local data',
      () async {
    await seedSpecies(source, 'Nome antigo', t0);
    final bytes = await DataExportService(source).buildArchiveBytes();

    await seedSpecies(target, 'Nome novo', t1);
    final summary = await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final species = await target.speciesDao.getById('species1');
    expect(species?.scientificName, 'Nome novo');
    expect(summary.skipped, greaterThanOrEqualTo(1));
  });

  test('tombstones survive the round trip', () async {
    await seedSpecies(source, 'Apagada', t1, deletedAt: t1);
    final bytes = await DataExportService(source).buildArchiveBytes();

    await DataImportService(target, FakePhotoStorage())
        .importFromBytes(bytes);

    final species = await target.speciesDao.getById('species1');
    expect(species, isNotNull);
    expect(species!.deletedAt, t1);
  });

  test('rejects files that are not a Polypodium backup', () async {
    final service = DataImportService(target, FakePhotoStorage());
    await expectLater(
      service.importFromBytes(Uint8List.fromList('not a backup'.codeUnits)),
      throwsA(isA<InvalidBackupException>()),
    );
  });
}
