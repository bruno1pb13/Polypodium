import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/string_utils.dart';
import '../providers/species_providers.dart';
import '../../domain/species_model.dart';

part 'species_search_providers.g.dart';

@riverpod
class SpeciesSearchQuery extends _$SpeciesSearchQuery {
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
class SpeciesSortOptionNotifier extends _$SpeciesSortOptionNotifier {
  @override
  SpeciesSortOption build() => SpeciesSortOption.popularAZ;

  void setSortOption(SpeciesSortOption option) => state = option;
}

@riverpod
Future<List<SpeciesModel>> filteredSortedSpecies(Ref ref) async {
  final query = ref.watch(speciesSearchQueryProvider).normalize();
  final sortOption = ref.watch(speciesSortOptionNotifierProvider);

  final speciesList = await ref.watch(speciesNotifierProvider.future);

  var filtered = speciesList.where((s) {
    return s.popularName.normalize().contains(query) ||
           s.scientificName.normalize().contains(query);
  }).toList();

  switch (sortOption) {
    case SpeciesSortOption.popularAZ:
      filtered.sort((a, b) => a.popularName.compareTo(b.popularName));
    case SpeciesSortOption.popularZA:
      filtered.sort((a, b) => b.popularName.compareTo(a.popularName));
    case SpeciesSortOption.scientificAZ:
      filtered.sort((a, b) => a.scientificName.compareTo(b.scientificName));
    case SpeciesSortOption.scientificZA:
      filtered.sort((a, b) => b.scientificName.compareTo(a.scientificName));
    case SpeciesSortOption.dateAdded:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return filtered;
}
