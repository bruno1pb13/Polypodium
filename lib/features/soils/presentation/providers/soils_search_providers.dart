import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/string_utils.dart';
import '../providers/soils_providers.dart';
import '../../domain/soil_model.dart';

part 'soils_search_providers.g.dart';

@riverpod
class SoilSearchQuery extends _$SoilSearchQuery {
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
class SoilSortOptionNotifier extends _$SoilSortOptionNotifier {
  @override
  SoilSortOption build() => SoilSortOption.nameAZ;

  void setSortOption(SoilSortOption option) => state = option;
}

@riverpod
Future<List<SoilModel>> filteredSortedSoils(Ref ref) async {
  final query = ref.watch(soilSearchQueryProvider).normalize();
  final sortOption = ref.watch(soilSortOptionNotifierProvider);

  final soilsList = await ref.watch(soilsNotifierProvider.future);

  var filtered = soilsList.where((s) {
    return s.name.normalize().contains(query) ||
           (s.composition?.normalize().contains(query) ?? false);
  }).toList();

  switch (sortOption) {
    case SoilSortOption.nameAZ:
      filtered.sort((a, b) => a.name.compareTo(b.name));
    case SoilSortOption.nameZA:
      filtered.sort((a, b) => b.name.compareTo(a.name));
    case SoilSortOption.dateAdded:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return filtered;
}
