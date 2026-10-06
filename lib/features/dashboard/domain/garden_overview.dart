import '../../../core/enums.dart';
import '../../agenda/domain/agenda_task.dart';
import '../../entries/domain/entry_model.dart';
import '../../plants/domain/plant_model.dart';

/// What the home dashboard shows about the garden, computed from the plants,
/// the agenda and the pest and chlorosis entries.
class GardenOverview {
  final List<PlantWithSpecies> activePlants;

  /// Overdue and due-today tasks, most overdue first.
  final List<AgendaTask> dueTasks;

  /// Tasks due after today, within the agenda horizon.
  final int upcomingCount;

  final int needsWaterCount;
  final int pestCount;
  final int chlorosisCount;
  final int pesticideDueCount;

  /// Active plants with no pending watering or pesticide and no active pest
  /// or chlorosis.
  final int healthyCount;

  /// Active plants that need attention first, then by watering needs.
  final List<PlantWithSpecies> spotlight;

  const GardenOverview({
    required this.activePlants,
    required this.dueTasks,
    required this.upcomingCount,
    required this.needsWaterCount,
    required this.pestCount,
    required this.chlorosisCount,
    required this.pesticideDueCount,
    required this.healthyCount,
    required this.spotlight,
  });

  int get activeCount => activePlants.length;

  /// Share of active plants that are [healthyCount], 0–1 (1 when empty).
  double get healthyRatio =>
      activeCount == 0 ? 1 : healthyCount / activeCount;
}

/// Builds the dashboard numbers.
///
/// [conditionEntries] are the pest and chlorosis entries of every plant,
/// newest first. A pest or chlorosis is active when the plant's latest entry
/// of that type has a value above 0, like in the plant list.
GardenOverview buildGardenOverview({
  required List<PlantWithSpecies> plants,
  required List<AgendaTask> tasks,
  required List<EntryModel> conditionEntries,
}) {
  final active = [
    for (final p in plants)
      if (p.plant.isActive) p,
  ];
  final activeIds = {for (final p in active) p.plant.id};

  final pests = _activeConditions(conditionEntries, EntryType.pest);
  final chlorosis = _activeConditions(conditionEntries, EntryType.chlorosis);
  bool hasIssue(PlantWithSpecies p) =>
      p.needsWatering ||
      p.needsPesticideReapplication ||
      pests.contains(p.plant.id) ||
      chlorosis.contains(p.plant.id);

  final dueTasks = [
    for (final t in tasks)
      if (t.isDue) t,
  ];

  final spotlight = [...active]..sort((a, b) {
      final byIssue = (hasIssue(b) ? 1 : 0).compareTo(hasIssue(a) ? 1 : 0);
      if (byIssue != 0) return byIssue;
      // Plants without a watering schedule go after the scheduled ones.
      final byWater = (b.daysRelativeToSchedule ?? _unscheduled)
          .compareTo(a.daysRelativeToSchedule ?? _unscheduled);
      if (byWater != 0) return byWater;
      return a.plant.nickname
          .toLowerCase()
          .compareTo(b.plant.nickname.toLowerCase());
    });

  return GardenOverview(
    activePlants: active,
    dueTasks: dueTasks,
    upcomingCount: tasks.length - dueTasks.length,
    needsWaterCount: active.where((p) => p.needsWatering).length,
    pestCount: pests.where(activeIds.contains).length,
    chlorosisCount: chlorosis.where(activeIds.contains).length,
    pesticideDueCount:
        active.where((p) => p.needsPesticideReapplication).length,
    healthyCount: active.where((p) => !hasIssue(p)).length,
    spotlight: spotlight,
  );
}

const _unscheduled = -1 << 30;

/// Plants whose latest [type] entry (newest first in [entries]) is active.
Set<String> _activeConditions(List<EntryModel> entries, EntryType type) {
  final seen = <String>{};
  final active = <String>{};
  for (final e in entries) {
    if (e.type != type || !seen.add(e.plantId)) continue;
    if ((e.numericValue ?? 1) > 0) active.add(e.plantId);
  }
  return active;
}
