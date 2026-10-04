import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../plants/presentation/providers/plants_providers.dart';
import '../../../reminders/presentation/providers/reminders_providers.dart';
import '../../domain/agenda_task.dart';

part 'agenda_providers.g.dart';

/// Pending tasks of all active plants. Rebuilds when plants (last watering,
/// last pesticide) or reminders/entries change, so actions taken from the
/// agenda drop their row right away.
@riverpod
Future<List<AgendaTask>> agendaTasks(Ref ref) async {
  final plants = ref.watch(plantsWithSpeciesProvider.future);
  final reminders = ref.watch(allRemindersProvider.future);
  return buildAgendaTasks(plants: await plants, reminders: await reminders);
}

/// Number of overdue and due-today tasks, for the navigation badge.
@riverpod
int agendaDueCount(Ref ref) =>
    ref.watch(agendaTasksProvider).value?.where((t) => t.isDue).length ?? 0;
