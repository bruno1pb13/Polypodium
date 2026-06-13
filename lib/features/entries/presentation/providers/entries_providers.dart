import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/storage/photo_storage.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../../../core/enums.dart';
import '../../data/entries_repository.dart';
import '../../domain/entry_model.dart';

part 'entries_providers.g.dart';

final latestPlantPhotoProvider =
    StreamProvider.autoDispose.family<String?, String>((ref, plantId) {
  final db = ref.watch(appDatabaseProvider);
  return db.entriesDao.watchLatestPhotoPath(plantId);
});

@Riverpod(keepAlive: true)
PhotoStorage photoStorage(Ref ref) => PhotoStorage();

@Riverpod(keepAlive: true)
EntriesRepository entriesRepository(Ref ref) {
  return EntriesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(photoStorageProvider),
  );
}

@riverpod
class EntriesNotifier extends _$EntriesNotifier {
  @override
  Stream<List<EntryModel>> build(String plantId) =>
      ref.watch(entriesRepositoryProvider).watchByPlant(plantId);

  Future<void> create(EntryModel entry) async {
    await ref.read(entriesRepositoryProvider).create(entry);
    if (entry.type == EntryType.irrigation) {
      await ref.read(plantsRepositoryProvider).refreshPlantStatus(plantId);
    }
  }

  Future<void> delete(String id, {String? photoPath}) async {
    final entry = await ref.read(entriesRepositoryProvider).getById(id);
    if (entry?.type == EntryType.history) {
      throw Exception('Registros de histórico não podem ser removidos.');
    }
    await ref.read(entriesRepositoryProvider).delete(id, photoPath: photoPath);

    if (entry?.type == EntryType.irrigation) {
      await ref.read(plantsRepositoryProvider).refreshPlantStatus(plantId);
    }
  }
}
