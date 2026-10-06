import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enums.dart';
import '../../../agenda/presentation/providers/agenda_providers.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../domain/garden_overview.dart';

part 'dashboard_providers.g.dart';

/// Entries of every plant from the last [activityWindowDays] days.
@riverpod
Stream<List<EntryModel>> recentGardenEntries(Ref ref) {
  final now = DateTime.now();
  final since =
      DateTime(now.year, now.month, now.day - (activityWindowDays - 1));
  return ref.watch(entriesRepositoryProvider).watchSince(since);
}

/// Pest and chlorosis entries of every plant, to tell which are active.
@riverpod
Stream<List<EntryModel>> gardenConditionEntries(Ref ref) => ref
    .watch(entriesRepositoryProvider)
    .watchOfTypes(const [EntryType.pest, EntryType.chlorosis]);

/// Everything the home dashboard shows, rebuilt as plants, reminders and
/// entries change.
@riverpod
Future<GardenOverview> gardenOverview(Ref ref) async {
  final plants = ref.watch(plantsWithSpeciesProvider.future);
  final tasks = ref.watch(agendaTasksProvider.future);
  final recent = ref.watch(recentGardenEntriesProvider.future);
  final conditions = ref.watch(gardenConditionEntriesProvider.future);
  return buildGardenOverview(
    plants: await plants,
    tasks: await tasks,
    recentEntries: await recent,
    conditionEntries: await conditions,
  );
}
