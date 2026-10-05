import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/presentation/providers/entry_filters_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<Set<EntryType>> loadFilters() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final sub =
        container.listen(entryFiltersNotifierProvider('p1'), (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();
    return container.read(entryFiltersNotifierProvider('p1'));
  }

  test('types added after the filter was saved start out visible', () async {
    // Saved before repotting existed, with pruning hidden.
    SharedPreferences.setMockInitialValues({
      'entry_filters_p1': [
        for (final t in EntryType.values)
          if (t != EntryType.pruning && t != EntryType.repotting) t.name,
      ],
    });

    final filters = await loadFilters();
    expect(filters, contains(EntryType.repotting));
    expect(filters, isNot(contains(EntryType.pruning)));
  });

  test('a type hidden after it existed stays hidden; unknown names are dropped',
      () async {
    SharedPreferences.setMockInitialValues({
      'entry_filters_p1': ['irrigation', 'grafting'],
      'entry_filters_known_p1': [
        for (final t in EntryType.values) t.name,
        'grafting',
      ],
    });

    expect(await loadFilters(), {EntryType.irrigation});
  });
}
