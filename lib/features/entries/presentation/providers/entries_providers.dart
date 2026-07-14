import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/storage/photo_storage_provider.dart';
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
EntriesRepository entriesRepository(Ref ref) {
  return EntriesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(photoStorageProvider),
  );
}

@Riverpod(keepAlive: true)
EntryMutations entryMutations(Ref ref) => EntryMutations(ref);

/// Entry create/delete plus their side effects (plant status refresh, sync
/// trigger). Lives in a keepAlive provider so in-flight work survives the
/// autoDispose lifecycle of the notifiers/screens that initiate it — an
/// autoDispose Ref becomes unusable after the first await if nothing is
/// watching the provider (e.g. bulk entry creation for unwatched plants).
class EntryMutations {
  EntryMutations(this._ref);

  final Ref _ref;

  Future<void> create(EntryModel entry) async {
    await _ref.read(entriesRepositoryProvider).create(entry);
    if (entry.type == EntryType.irrigation) {
      await _ref
          .read(plantsRepositoryProvider)
          .refreshPlantStatus(entry.plantId);
    }
    _triggerSync();
  }

  Future<void> delete(String id) async {
    final entry = await _ref.read(entriesRepositoryProvider).getById(id);
    await _ref.read(entriesRepositoryProvider).delete(id);

    if (entry != null && entry.type == EntryType.irrigation) {
      await _ref
          .read(plantsRepositoryProvider)
          .refreshPlantStatus(entry.plantId);
    }
    _triggerSync();
  }

  /// Trigger immediate sync if logged in.
  void _triggerSync() {
    try {
      final syncService = _ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        _ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }
}

@riverpod
class EntriesNotifier extends _$EntriesNotifier {
  @override
  Stream<List<EntryModel>> build(String plantId) =>
      ref.watch(entriesRepositoryProvider).watchByPlant(plantId);

  // The synchronous ref.read hands the work to the keepAlive mutations
  // service before any await, so it completes even if this autoDispose
  // notifier is disposed mid-operation.
  Future<void> create(EntryModel entry) =>
      ref.read(entryMutationsProvider).create(entry);

  Future<void> delete(String id) =>
      ref.read(entryMutationsProvider).delete(id);
}
