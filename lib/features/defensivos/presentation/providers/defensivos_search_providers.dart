import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/string_utils.dart';
import '../providers/defensivos_providers.dart';
import '../../domain/defensivo_model.dart';

part 'defensivos_search_providers.g.dart';

@riverpod
class DefensivoSearchQuery extends _$DefensivoSearchQuery {
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
class DefensivoSortOptionNotifier extends _$DefensivoSortOptionNotifier {
  @override
  DefensivoSortOption build() => DefensivoSortOption.nameAZ;

  void setSortOption(DefensivoSortOption option) => state = option;
}

@riverpod
Future<List<DefensivoModel>> filteredSortedDefensivos(Ref ref) async {
  final query = ref.watch(defensivoSearchQueryProvider).normalize();
  final sortOption = ref.watch(defensivoSortOptionNotifierProvider);

  final defensivosList = await ref.watch(defensivosNotifierProvider.future);

  var filtered = defensivosList.where((d) {
    return d.name.normalize().contains(query) ||
        (d.composition?.normalize().contains(query) ?? false);
  }).toList();

  switch (sortOption) {
    case DefensivoSortOption.nameAZ:
      filtered.sort((a, b) => a.name.compareTo(b.name));
    case DefensivoSortOption.nameZA:
      filtered.sort((a, b) => b.name.compareTo(a.name));
    case DefensivoSortOption.dateAdded:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return filtered;
}
