import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/enums.dart';

part 'entry_filters_provider.g.dart';

@riverpod
class EntryFiltersNotifier extends _$EntryFiltersNotifier {
  static const _prefPrefix = 'entry_filters_';
  static const _knownPrefix = 'entry_filters_known_';

  /// Types that existed before saved filters recorded the known types.
  static final _legacyTypes =
      EntryType.values.where((t) => t.index <= EntryType.history.index);

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
      final known = prefs
              .getStringList('$_knownPrefix$plantId')
              ?.map(EntryType.fromName)
              .nonNulls
              .toSet() ??
          _legacyTypes.toSet();
      // Types added after the filter was saved start out visible; names
      // this version doesn't know are dropped.
      state = {
        ...saved.map(EntryType.fromName).nonNulls,
        ...EntryType.values.where((t) => !known.contains(t)),
      };
    }
  }

  Future<void> _save(SharedPreferences prefs, Set<EntryType> types) async {
    await prefs.setStringList(
      '$_prefPrefix$plantId',
      types.map((e) => e.name).toList(),
    );
    await prefs.setStringList(
      '$_knownPrefix$plantId',
      EntryType.values.map((e) => e.name).toList(),
    );
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
    await _save(prefs, newState);
  }

  Future<void> selectAll() async {
    state = EntryType.values.toSet();
    final prefs = await SharedPreferences.getInstance();
    await _save(prefs, state);
  }
}

@riverpod
List<EntryType> availableEntryTypes(Ref ref) {
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
