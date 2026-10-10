import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/string_utils.dart';
import '../providers/plants_providers.dart';
import '../../domain/plant_model.dart';

part 'plant_search_providers.g.dart';

@riverpod
class PlantSearchQuery extends _$PlantSearchQuery {
  Timer? _debounceTimer;

  @override
  String build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return '';
  }

  void setQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = query;
    });
  }
}

@riverpod
class PlantSortOptionNotifier extends _$PlantSortOptionNotifier {
  @override
  PlantSortOption build() => PlantSortOption.wateringNeeds;

  void setSortOption(PlantSortOption option) => state = option;
}

/// Whether the Home list also shows plants that are no longer active (dead,
/// donated or archived). Off by default.
@riverpod
class PlantShowArchivedNotifier extends _$PlantShowArchivedNotifier {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
Future<List<PlantWithSpecies>> filteredSortedPlants(Ref ref) async {
  // Watch synchronous providers FIRST to ensure they are not disposed during await
  final query = ref.watch(plantSearchQueryProvider).normalize();
  final sortOption = ref.watch(plantSortOptionNotifierProvider);
  final showArchived = ref.watch(plantShowArchivedNotifierProvider);

  final plantsAsync = await ref.watch(plantsWithSpeciesProvider.future);

  Iterable<PlantWithSpecies> filtered = plantsAsync;

  if (!showArchived) {
    filtered = filtered.where((p) => p.plant.isActive);
  }

  if (query.isNotEmpty) {
    filtered = filtered.where((p) =>
        p.plant.nickname.normalize().contains(query) ||
        p.species.popularName.normalize().contains(query) ||
        p.species.scientificName.normalize().contains(query) ||
        (p.pot?.name.normalize().contains(query) ?? false) ||
        matchesPlantShortCode(query, p.plant.shortCode));
  }

  final sorted = filtered.toList();

  switch (sortOption) {
    case PlantSortOption.wateringNeeds:
      sorted.sort((a, b) {
        final aVal = a.daysRelativeToSchedule ?? -999;
        final bVal = b.daysRelativeToSchedule ?? -999;
        return bVal.compareTo(aVal);
      });
      break;
    case PlantSortOption.nameAZ:
      sorted.sort((a, b) => a.plant.nickname
          .toLowerCase()
          .compareTo(b.plant.nickname.toLowerCase()));
      break;
    case PlantSortOption.nameZA:
      sorted.sort((a, b) => b.plant.nickname
          .toLowerCase()
          .compareTo(a.plant.nickname.toLowerCase()));
      break;
    case PlantSortOption.lastWatered:
      sorted.sort((a, b) {
        final aDate = a.plant.lastIrrigatedAt ?? DateTime(0);
        final bDate = b.plant.lastIrrigatedAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });
      break;
    case PlantSortOption.dateAdded:
      sorted.sort((a, b) => b.plant.createdAt.compareTo(a.plant.createdAt));
      break;
  }

  return sorted;
}
