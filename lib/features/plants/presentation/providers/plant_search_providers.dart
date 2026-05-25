import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/enums.dart';
import '../providers/plants_providers.dart';
import '../../domain/plant_model.dart';

part 'plant_search_providers.g.dart';

@riverpod
class PlantSearchQuery extends _$PlantSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

@riverpod
class PlantSortOptionNotifier extends _$PlantSortOptionNotifier {
  @override
  PlantSortOption build() => PlantSortOption.wateringNeeds;

  void setSortOption(PlantSortOption option) => state = option;
}

@riverpod
Future<List<PlantWithSpecies>> filteredSortedPlants(Ref ref) async {
  // Watch synchronous providers FIRST to ensure they are not disposed during await
  final query = ref.watch(plantSearchQueryProvider).toLowerCase();
  final sortOption = ref.watch(plantSortOptionNotifierProvider);

  final plantsAsync = await ref.watch(plantsWithSpeciesProvider.future);

  Iterable<PlantWithSpecies> filtered = plantsAsync;

  if (query.isNotEmpty) {
    filtered = filtered.where((p) =>
        p.plant.nickname.toLowerCase().contains(query) ||
        p.species.popularName.toLowerCase().contains(query) ||
        p.species.scientificName.toLowerCase().contains(query));
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
