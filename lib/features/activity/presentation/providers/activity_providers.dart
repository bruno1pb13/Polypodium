import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../domain/garden_activity.dart';

part 'activity_providers.g.dart';

/// How far back the activity screen looks.
@riverpod
class ActivityRangeNotifier extends _$ActivityRangeNotifier {
  @override
  ActivityRange build() => ActivityRange.month;

  void set(ActivityRange range) => state = range;
}

/// Entries of every plant within the selected range, newest first.
@riverpod
Stream<List<EntryModel>> gardenEntriesInRange(Ref ref) {
  final range = ref.watch(activityRangeNotifierProvider);
  return ref
      .watch(entriesRepositoryProvider)
      .watchSince(range.start(DateTime.now()));
}

/// The garden's logging history, rebuilt as plants and entries change.
@riverpod
Future<GardenActivity> gardenActivity(Ref ref) async {
  final plants = ref.watch(plantsWithSpeciesProvider.future);
  final entries = ref.watch(gardenEntriesInRangeProvider.future);
  return buildGardenActivity(plants: await plants, entries: await entries);
}
