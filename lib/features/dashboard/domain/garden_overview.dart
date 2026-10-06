import '../../../core/enums.dart';
import '../../agenda/domain/agenda_task.dart';
import '../../entries/domain/entry_model.dart';
import '../../plants/domain/plant_model.dart';

/// Entries logged on one calendar day, split into waterings and other care.
class DayActivity {
  final DateTime day;
  final int irrigation;
  final int care;

  const DayActivity({
    required this.day,
    required this.irrigation,
    required this.care,
  });

  int get total => irrigation + care;
}

/// Active plants of one location; [name] is null for plants without one.
typedef LocationCount = ({String? name, int count});

/// A recent entry together with the plant it belongs to.
typedef RecentEntry = ({EntryModel entry, PlantWithSpecies plant});

/// What the home dashboard shows about the garden, computed from the plants,
/// the agenda and the entries of the last [activityWindowDays] days.
class GardenOverview {
  final List<PlantWithSpecies> activePlants;
  final int speciesCount;
  final int locationCount;

  /// Overdue and due-today tasks, most overdue first.
  final List<AgendaTask> dueTasks;
  final int overdueCount;

  /// Tasks due after today, within the agenda horizon.
  final int upcomingCount;

  final int needsWaterCount;
  final int pestCount;
  final int chlorosisCount;
  final int pesticideDueCount;

  /// Active plants with no pending watering or pesticide and no active pest
  /// or chlorosis.
  final int healthyCount;

  /// One item per day of the last [chartDays] days, oldest first; the last
  /// one is today.
  final List<DayActivity> activity;

  /// Entries logged in the last [activityWindowDays] days.
  final int entriesInWindow;

  /// Consecutive days with at least one entry, ending today (or yesterday,
  /// while nothing was logged today yet).
  final int streakDays;

  /// Most populated locations first; plants without one come last.
  final List<LocationCount> byLocation;

  /// Newest entries first.
  final List<RecentEntry> recent;

  /// Active plants that need attention first, then by watering needs.
  final List<PlantWithSpecies> spotlight;

  const GardenOverview({
    required this.activePlants,
    required this.speciesCount,
    required this.locationCount,
    required this.dueTasks,
    required this.overdueCount,
    required this.upcomingCount,
    required this.needsWaterCount,
    required this.pestCount,
    required this.chlorosisCount,
    required this.pesticideDueCount,
    required this.healthyCount,
    required this.activity,
    required this.entriesInWindow,
    required this.streakDays,
    required this.byLocation,
    required this.recent,
    required this.spotlight,
  });

  int get activeCount => activePlants.length;

  /// Share of active plants that are [healthyCount], 0–1 (1 when empty).
  double get healthyRatio =>
      activeCount == 0 ? 1 : healthyCount / activeCount;
}

/// How many days of entries the dashboard looks back on.
const activityWindowDays = 30;

/// How many days the activity chart shows.
const chartDays = 14;

/// How many entries the recent activity card lists.
const recentEntriesShown = 5;

/// Builds the dashboard numbers.
///
/// [recentEntries] are the entries of the last [activityWindowDays] days and
/// [conditionEntries] the pest and chlorosis entries (any date), both of
/// every plant. A pest or chlorosis is active when the plant's latest entry
/// of that type has a value above 0, like in the plant list.
GardenOverview buildGardenOverview({
  required List<PlantWithSpecies> plants,
  required List<AgendaTask> tasks,
  required List<EntryModel> recentEntries,
  required List<EntryModel> conditionEntries,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);

  final active = [
    for (final p in plants)
      if (p.plant.isActive) p,
  ];
  final byId = {for (final p in plants) p.plant.id: p};
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

  // Activity per calendar day, keyed by days before today.
  final irrigationByDay = <int, int>{};
  final careByDay = <int, int>{};
  var entriesInWindow = 0;
  for (final e in recentEntries) {
    if (!byId.containsKey(e.plantId)) continue;
    final d = e.date.toLocal();
    final ago = today.difference(DateTime(d.year, d.month, d.day)).inDays;
    if (ago < 0 || ago >= activityWindowDays) continue;
    entriesInWindow++;
    final bucket =
        e.type == EntryType.irrigation ? irrigationByDay : careByDay;
    bucket[ago] = (bucket[ago] ?? 0) + 1;
  }
  bool loggedOn(int ago) =>
      (irrigationByDay[ago] ?? 0) + (careByDay[ago] ?? 0) > 0;
  var streak = 0;
  for (var ago = loggedOn(0) ? 0 : 1;
      ago < activityWindowDays && loggedOn(ago);
      ago++) {
    streak++;
  }

  final locationCounts = <String?, int>{};
  for (final p in active) {
    final name = p.location?.name;
    locationCounts[name] = (locationCounts[name] ?? 0) + 1;
  }
  final byLocation = [
    for (final e in locationCounts.entries) (name: e.key, count: e.value),
  ]..sort((a, b) {
      if ((a.name == null) != (b.name == null)) return a.name == null ? 1 : -1;
      final byCount = b.count.compareTo(a.count);
      if (byCount != 0) return byCount;
      return (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase());
    });

  final recent = <RecentEntry>[];
  for (final e in recentEntries) {
    final plant = byId[e.plantId];
    if (plant == null) continue;
    recent.add((entry: e, plant: plant));
    if (recent.length == recentEntriesShown) break;
  }

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
    speciesCount: {for (final p in active) p.plant.speciesId}.length,
    locationCount: {
      for (final p in active)
        if (p.location != null) p.location!.id,
    }.length,
    dueTasks: dueTasks,
    overdueCount: dueTasks.where((t) => t.bucket == AgendaBucket.overdue).length,
    upcomingCount: tasks.length - dueTasks.length,
    needsWaterCount: active.where((p) => p.needsWatering).length,
    pestCount: pests.where(activeIds.contains).length,
    chlorosisCount: chlorosis.where(activeIds.contains).length,
    pesticideDueCount:
        active.where((p) => p.needsPesticideReapplication).length,
    healthyCount: active.where((p) => !hasIssue(p)).length,
    activity: [
      for (var ago = chartDays - 1; ago >= 0; ago--)
        DayActivity(
          day: DateTime(today.year, today.month, today.day - ago),
          irrigation: irrigationByDay[ago] ?? 0,
          care: careByDay[ago] ?? 0,
        ),
    ],
    entriesInWindow: entriesInWindow,
    streakDays: streak,
    byLocation: byLocation,
    recent: recent,
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
