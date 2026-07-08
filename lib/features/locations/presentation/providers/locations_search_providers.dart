import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/string_utils.dart';
import '../providers/locations_providers.dart';
import '../../domain/location_model.dart';

part 'locations_search_providers.g.dart';

@riverpod
class LocationSearchQuery extends _$LocationSearchQuery {
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
class LocationSortOptionNotifier extends _$LocationSortOptionNotifier {
  @override
  LocationSortOption build() => LocationSortOption.nameAZ;

  void setSortOption(LocationSortOption option) => state = option;
}

@riverpod
Future<List<LocationModel>> filteredSortedLocations(Ref ref) async {
  final query = ref.watch(locationSearchQueryProvider).normalize();
  final sortOption = ref.watch(locationSortOptionNotifierProvider);

  final locationsList = await ref.watch(locationsNotifierProvider.future);

  var filtered = locationsList.where((l) {
    return l.name.normalize().contains(query) ||
           (l.description?.normalize().contains(query) ?? false);
  }).toList();

  switch (sortOption) {
    case LocationSortOption.nameAZ:
      filtered.sort((a, b) => a.name.compareTo(b.name));
    case LocationSortOption.nameZA:
      filtered.sort((a, b) => b.name.compareTo(a.name));
    case LocationSortOption.dateAdded:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return filtered;
}
