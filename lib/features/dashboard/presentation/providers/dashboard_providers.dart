import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enums.dart';
import '../../../agenda/presentation/providers/agenda_providers.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../domain/garden_overview.dart';

part 'dashboard_providers.g.dart';

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
  final conditions = ref.watch(gardenConditionEntriesProvider.future);
  return buildGardenOverview(
    plants: await plants,
    tasks: await tasks,
    conditionEntries: await conditions,
  );
}
