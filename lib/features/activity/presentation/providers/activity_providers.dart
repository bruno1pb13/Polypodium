import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../domain/garden_activity.dart';

part 'activity_providers.g.dart';

/// Entries of every plant, newest first.
@riverpod
Stream<List<EntryModel>> allGardenEntries(Ref ref) =>
    ref.watch(entriesRepositoryProvider).watchAll();

/// The garden's logging history, rebuilt as plants and entries change.
@riverpod
Future<GardenActivity> gardenActivity(Ref ref) async {
  final plants = ref.watch(plantsWithSpeciesProvider.future);
  final entries = ref.watch(allGardenEntriesProvider.future);
  return buildGardenActivity(plants: await plants, entries: await entries);
}
