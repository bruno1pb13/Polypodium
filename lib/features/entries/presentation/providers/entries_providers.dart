import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/storage/photo_storage_provider.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../../reminders/domain/reminder_model.dart';
import '../../../../core/enums.dart';
import '../../data/entries_repository.dart';
import '../../domain/entry_details.dart';
import '../../domain/entry_model.dart';

import '../../../../core/sync/sync_providers.dart';

part 'entries_providers.g.dart';

typedef PlantAlertStatus = ({
  bool hasActiveChlorosis,
  int? chlorosisSeverity,
  bool hasActivePest,
  int? pestSeverity,
});

const PlantAlertStatus noPlantAlerts = (
  hasActiveChlorosis: false,
  chlorosisSeverity: null,
  hasActivePest: false,
  pestSeverity: null,
);

/// For a given plant, tells whether chlorosis and/or pest are currently active,
/// and what the severity of the most recent entry is.
/// A condition is "active" when the most recent entry of that type has
/// numericValue > 0. numericValue == 0 means the condition was resolved.
final plantAlertStatusProvider =
    StreamProvider.autoDispose.family<PlantAlertStatus, String>(
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

/// The plant's cover: the photo picked for it, or its latest photo.
final plantCoverPhotoProvider =
    StreamProvider.autoDispose.family<String?, String>((ref, plantId) {
  final db = ref.watch(appDatabaseProvider);
  return db.entriesDao.watchCoverPhotoPath(plantId);
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

  Future<void> create(EntryModel entry) => createMany([entry]);

  /// Creates [entries] (typically one per plant, for bulk actions) and
  /// refreshes the affected plants' status, rescheduling notifications and
  /// triggering sync once for the whole batch instead of once per entry.
  /// A repotting entry with a new soil moves its plant to that soil.
  Future<void> createMany(List<EntryModel> entries) async {
    if (entries.isEmpty) return;
    final entriesRepo = _ref.read(entriesRepositoryProvider);
    final plantsRepo = _ref.read(plantsRepositoryProvider);
    var needsReschedule = false;
    for (final entry in entries) {
      await entriesRepo.create(entry);
      if (entry.type == EntryType.irrigation) {
        await plantsRepo.refreshPlantStatus(entry.plantId, reschedule: false);
        needsReschedule = true;
      } else if (entry.type == EntryType.pesticide) {
        await plantsRepo.refreshPesticideStatus(entry.plantId,
            reschedule: false);
        needsReschedule = true;
      } else if (reminderEntryTypes.contains(entry.type)) {
        // Moves the derived due date of a recurring reminder of this type.
        needsReschedule = true;
      }
    }
    if (needsReschedule) await plantsRepo.rescheduleNotifications();
    for (final entry in entries) {
      if (entry.type == EntryType.repotting) await _applyNewSoil(entry);
    }
    _triggerSync();
  }

  /// Saves the plant with the soil picked on a repotting [entry], through
  /// [PlantMutations.save] so the change gets its history entry and syncs
  /// like an edit. Only done here, where the entry is created: a repotting
  /// pulled by sync arrives with the plant row its device already updated.
  Future<void> _applyNewSoil(EntryModel entry) async {
    final details = entry.details;
    if (details is! RepottingDetails) return;
    final soilId = details.newSoilId;
    if (soilId == null) return;
    final plant =
        await _ref.read(plantsRepositoryProvider).getById(entry.plantId);
    if (plant == null || plant.soilId == soilId) return;
    await _ref.read(plantMutationsProvider).save(plant.copyWith(soilId: soilId));
  }

  /// Records a plain irrigation entry, dated now, for each of [plantIds].
  Future<void> recordIrrigation(Iterable<String> plantIds) {
    final now = DateTime.now();
    return createMany([
      for (final plantId in plantIds)
        EntryModel(
          id: const Uuid().v4(),
          plantId: plantId,
          date: now,
          type: EntryType.irrigation,
          createdAt: now,
        ),
    ]);
  }

  Future<void> delete(String id) async {
    final entry = await _ref.read(entriesRepositoryProvider).getById(id);
    await _ref.read(entriesRepositoryProvider).delete(id);

    if (entry != null && entry.type == EntryType.irrigation) {
      await _ref
          .read(plantsRepositoryProvider)
          .refreshPlantStatus(entry.plantId);
    } else if (entry != null && entry.type == EntryType.pesticide) {
      await _ref
          .read(plantsRepositoryProvider)
          .refreshPesticideStatus(entry.plantId);
    } else if (entry != null && reminderEntryTypes.contains(entry.type)) {
      await _ref.read(plantsRepositoryProvider).rescheduleNotifications();
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
