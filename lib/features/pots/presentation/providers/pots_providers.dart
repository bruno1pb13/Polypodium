import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../plants/domain/plant_model.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../data/pots_repository.dart';
import '../../domain/pot_model.dart';
import '../../domain/pot_with_plants.dart';

part 'pots_providers.g.dart';

@Riverpod(keepAlive: true)
PotsRepository potsRepository(Ref ref) => PotsRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(entriesRepositoryProvider),
    );

@riverpod
class PotsNotifier extends _$PotsNotifier {
  @override
  Stream<List<PotModel>> build() =>
      ref.watch(potsRepositoryProvider).watchAll();
}

@Riverpod(keepAlive: true)
PotMutations potMutations(Ref ref) => PotMutations(ref);

/// Pot save/delete and plant moves plus the sync trigger. Lives in a
/// keepAlive provider for the same reason as PlantMutations.
class PotMutations {
  PotMutations(this._ref);

  final Ref _ref;

  PotsRepository get _repo => _ref.read(potsRepositoryProvider);

  Future<void> save(PotModel pot) async {
    await _repo.save(pot);
    _triggerSync();
  }

  /// Returns how many plants were taken out of the pot.
  Future<int> delete(String potId) async {
    final count = await _repo.delete(potId);
    _triggerSync();
    return count;
  }

  /// See [PotsRepository.movePlantsToPot]. Returns the plants moved.
  Future<List<String>> movePlants(Iterable<String> plantIds, String? potId,
      {bool recordEntry = true, bool applyPotLocation = true}) async {
    final moved = await _repo.movePlantsToPot(plantIds, potId,
        recordEntry: recordEntry, applyPotLocation: applyPotLocation);
    await _afterMove(moved, recordEntry: recordEntry);
    return moved;
  }

  Future<List<String>> moveAllPlants(String fromPotId, String? toPotId) async {
    final moved = await _repo.moveAllPlants(fromPotId, toPotId);
    await _afterMove(moved, recordEntry: true);
    return moved;
  }

  /// A recorded move is a repotting entry, which a recurring repotting
  /// reminder counts from.
  Future<void> _afterMove(List<String> moved,
      {required bool recordEntry}) async {
    if (moved.isEmpty) return;
    if (recordEntry) {
      await _ref.read(plantsRepositoryProvider).rescheduleNotifications();
    }
    _triggerSync();
  }

  /// The active plants in [potId] right now; see
  /// [PotsRepository.activePlantIds].
  Future<List<String>> activePlantIds(String potId) =>
      _repo.activePlantIds(potId);

  Future<void> moveToLocation(String potId, String? locationId) async {
    await _repo.moveToLocation(potId, locationId);
    _triggerSync();
  }

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

/// Every live pot with its location and plants, ordered by name.
@riverpod
Future<List<PotWithPlants>> potsWithPlants(Ref ref) async {
  final potsFuture = ref.watch(potsNotifierProvider.future);
  final plantsFuture = ref.watch(plantsWithSpeciesProvider.future);
  final locationsFuture = ref.watch(locationsNotifierProvider.future);

  final pots = await potsFuture;
  final plants = await plantsFuture;
  final locations = await locationsFuture;

  final locationsById = {for (final l in locations) l.id: l};
  final plantsByPot = <String, List<PlantWithSpecies>>{};
  for (final p in plants) {
    final potId = p.plant.potId;
    if (potId != null) (plantsByPot[potId] ??= []).add(p);
  }
  return [
    for (final pot in pots)
      PotWithPlants(
        pot: pot,
        location: pot.locationId == null ? null : locationsById[pot.locationId],
        plants: plantsByPot[pot.id] ?? const [],
      ),
  ];
}

/// One pot with its plants; null when it doesn't exist or was deleted.
@riverpod
Future<PotWithPlants?> potWithPlants(Ref ref, String potId) async {
  final pots = await ref.watch(potsWithPlantsProvider.future);
  for (final p in pots) {
    if (p.pot.id == potId) return p;
  }
  return null;
}
