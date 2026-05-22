import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/storage/photo_storage.dart';
import '../../data/entries_repository.dart';
import '../../domain/entry_model.dart';

part 'entries_providers.g.dart';

@Riverpod(keepAlive: true)
PhotoStorage photoStorage(PhotoStorageRef ref) => PhotoStorage();

@Riverpod(keepAlive: true)
EntriesRepository entriesRepository(EntriesRepositoryRef ref) {
  return EntriesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(photoStorageProvider),
  );
}

@riverpod
class EntriesNotifier extends _$EntriesNotifier {
  @override
  Future<List<EntryModel>> build(String plantId) =>
      ref.watch(entriesRepositoryProvider).getByPlant(plantId);

  Future<void> create(EntryModel entry) async {
    await ref.read(entriesRepositoryProvider).create(entry);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id, {String? photoPath}) async {
    await ref.read(entriesRepositoryProvider).delete(id, photoPath: photoPath);
    ref.invalidateSelf();
    await future;
  }
}
