import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/storage/photo_storage.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../../../core/enums.dart';
import '../../data/entries_repository.dart';
import '../../domain/entry_model.dart';

import '../../../../core/sync/sync_providers.dart';

part 'entries_providers.g.dart';

/// For a given plant, tells whether chlorosis and/or pest are currently active,
/// and what the severity of the most recent entry is.
/// A condition is "active" when the most recent entry of that type has
/// numericValue > 0. numericValue == 0 means the condition was resolved.
final plantAlertStatusProvider = StreamProvider.autoDispose.family<
    ({
      bool hasActiveChlorosis,
      int? chlorosisSeverity,
      bool hasActivePest,
      int? pestSeverity,
    }),
    String>(
  (ref, plantId) {
    return ref
        .watch(entriesRepositoryProvider)
        .watchByPlant(plantId)
        .map((entries) {
      EntryModel? lastChlorosis;
      EntryModel? lastPest;

      for (final e in entries) {
        if (lastChlorosis == null && e.type == EntryType.chlorosis) {
          lastChlorosis = e;
        }
        if (lastPest == null && e.type == EntryType.pest) {
          lastPest = e;
        }
        if (lastChlorosis != null && lastPest != null) break;
      }

      final cNv = lastChlorosis?.numericValue;
      final pNv = lastPest?.numericValue;
      final chlorosisActive = lastChlorosis != null && (cNv ?? 1) > 0;
      final pestActive = lastPest != null && (pNv ?? 1) > 0;

      return (
        hasActiveChlorosis: chlorosisActive,
        chlorosisSeverity:
            chlorosisActive && cNv != null ? cNv.toInt() : null,
        hasActivePest: pestActive,
        pestSeverity: pestActive && pNv != null ? pNv.toInt() : null,
      );
    });
  },
);

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

    // Trigger immediate sync if logged in
    try {
      final syncService = ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }

  Future<void> delete(String id) async {
    final entry = await ref.read(entriesRepositoryProvider).getById(id);
    await ref.read(entriesRepositoryProvider).delete(id);

    if (entry?.type == EntryType.irrigation) {
      await ref.read(plantsRepositoryProvider).refreshPlantStatus(plantId);
    }

    // Trigger immediate sync if logged in
    try {
      final syncService = ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }
}
