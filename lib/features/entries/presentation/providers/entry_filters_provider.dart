import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/enums.dart';

part 'entry_filters_provider.g.dart';

@riverpod
class EntryFiltersNotifier extends _$EntryFiltersNotifier {
  static const _prefPrefix = 'entry_filters_';

  @override
  Set<EntryType> build(String plantId) {
    _loadFilters();
    // Default: show all filters
    return EntryType.values.toSet();
  }

  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('$_prefPrefix$plantId');
    if (saved != null) {
      final types = saved
          .map((e) => EntryType.values.firstWhere((t) => t.name == e))
          .toSet();
      state = types;
    }
  }

  Future<void> toggleFilter(EntryType type) async {
    final newState = Set<EntryType>.from(state);
    if (newState.contains(type)) {
      if (newState.length > 1) {
        newState.remove(type);
      }
    } else {
      newState.add(type);
    }
    state = newState;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$_prefPrefix$plantId',
      newState.map((e) => e.name).toList(),
    );
  }

  Future<void> selectAll() async {
    state = EntryType.values.toSet();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$_prefPrefix$plantId',
      EntryType.values.map((e) => e.name).toList(),
    );
  }
}

@riverpod
List<EntryType> availableEntryTypes(AvailableEntryTypesRef ref) {
  return EntryType.values;
}

@riverpod
class EntrySortNotifier extends _$EntrySortNotifier {
  static const _prefPrefix = 'entry_sort_';

  @override
  EntrySortOption build(String plantId) {
    _loadSort();
    return EntrySortOption.dateDesc;
  }

  Future<void> _loadSort() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('$_prefPrefix$plantId');
    if (saved != null) {
      state = EntrySortOption.values.firstWhere(
        (s) => s.name == saved,
        orElse: () => EntrySortOption.dateDesc,
      );
    }
  }

  Future<void> setSort(EntrySortOption sort) async {
    state = sort;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefPrefix$plantId', sort.name);
  }
}
