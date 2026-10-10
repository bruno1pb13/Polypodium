import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enums.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../plants/domain/plant_model.dart';
import '../../domain/pot_with_plants.dart';
import 'pots_providers.dart';

part 'pots_search_providers.g.dart';

@riverpod
class PotSearchQuery extends _$PotSearchQuery {
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
class PotSortOptionNotifier extends _$PotSortOptionNotifier {
  @override
  PotSortOption build() => PotSortOption.nameAZ;

  void setSortOption(PotSortOption option) => state = option;
}

/// Whether [pot] matches the normalized [query]: its name, notes, location
/// or the nickname or short code of a plant in it.
bool potMatchesQuery(PotWithPlants pot, String query) {
  if (query.isEmpty) return true;
  return pot.pot.name.normalize().contains(query) ||
      (pot.pot.notes?.normalize().contains(query) ?? false) ||
      (pot.location?.name.normalize().contains(query) ?? false) ||
      pot.plants.any((p) =>
          p.plant.nickname.normalize().contains(query) ||
          matchesPlantShortCode(query, p.plant.shortCode));
}

List<PotWithPlants> sortPots(List<PotWithPlants> pots, PotSortOption option) {
  final sorted = [...pots];
  int byName(PotWithPlants a, PotWithPlants b) =>
      a.pot.name.normalize().compareTo(b.pot.name.normalize());
  switch (option) {
    case PotSortOption.nameAZ:
      sorted.sort(byName);
    case PotSortOption.mostPlants:
      sorted.sort((a, b) {
        final byCount = b.plants.length.compareTo(a.plants.length);
        return byCount != 0 ? byCount : byName(a, b);
      });
    case PotSortOption.dateAdded:
      sorted.sort((a, b) => b.pot.createdAt.compareTo(a.pot.createdAt));
  }
  return sorted;
}

@riverpod
Future<List<PotWithPlants>> filteredSortedPots(Ref ref) async {
  final query = ref.watch(potSearchQueryProvider).normalize();
  final sortOption = ref.watch(potSortOptionNotifierProvider);
  final pots = await ref.watch(potsWithPlantsProvider.future);
  return sortPots(
      pots.where((p) => potMatchesQuery(p, query)).toList(), sortOption);
}
