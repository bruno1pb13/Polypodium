import '../../entries/domain/entry_model.dart';
import '../../plants/domain/plant_model.dart';

/// How many entries were logged on one calendar day.
class DayActivity {
  final DateTime day;
  final int count;

  /// Shade of the day in the heatmap: 0 for no entries, then 1–4 as
  /// [count] approaches the busiest day of the year.
  final int level;

  const DayActivity({
    required this.day,
    required this.count,
    required this.level,
  });
}

/// An entry together with the plant it belongs to.
typedef ActivityEntry = ({EntryModel entry, PlantWithSpecies plant});

/// The entries of one calendar day, newest first.
typedef ActivityDay = ({DateTime day, List<ActivityEntry> entries});

/// The garden's logging history: entries per day over the last year for the
/// heatmap, the streak and the entries of a range grouped by day.
class GardenActivity {
  /// One item per day of the last [heatmapDays] days, oldest first; the
  /// last one is today.
  final List<DayActivity> heatmap;

  /// Consecutive days with at least one entry, ending today (or yesterday,
  /// while nothing was logged today yet).
  final int streakDays;

  /// Days with entries, newest first.
  final List<ActivityDay> days;

  const GardenActivity({
    required this.heatmap,
    required this.streakDays,
    required this.days,
  });

  /// Entries in the heatmap's year.
  int get totalEntries => heatmap.fold(0, (sum, d) => sum + d.count);

  /// Days of the heatmap's year with at least one entry.
  int get activeDays => heatmap.where((d) => d.count > 0).length;
}

/// How many shades above "no entries" the heatmap uses.
const heatmapLevels = 4;

/// How far back the activity screen loads entries.
enum ActivityRange {
  month(30),
  quarter(90),
  year(365);

  const ActivityRange(this.days);

  final int days;

  /// Local midnight of the first day in the range ending [now].
  DateTime start(DateTime now) =>
      DateTime(now.year, now.month, now.day - (days - 1));
}

/// How many days the heatmap shows, whatever the [ActivityRange].
const heatmapDays = 365;

/// Builds the activity of [plants]: the heatmap and streak from
/// [entryDates] (the last [heatmapDays] days), the list from [entries] (the
/// selected range, newest first). Entries of plants not in [plants] are left
/// out.
GardenActivity buildGardenActivity({
  required List<PlantWithSpecies> plants,
  required List<EntryModel> entries,
  required List<EntryDate> entryDates,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);
  final byId = {for (final p in plants) p.plant.id: p};

  final days = <ActivityDay>[];
  for (final e in entries) {
    final plant = byId[e.plantId];
    if (plant == null) continue;
    final d = e.date.toLocal();
    final day = DateTime(d.year, d.month, d.day);
    if (days.isEmpty || days.last.day != day) {
      days.add((day: day, entries: []));
    }
    days.last.entries.add((entry: e, plant: plant));
  }

  // On UTC midnights so a DST change doesn't shave a day off.
  final todayUtc = DateTime.utc(today.year, today.month, today.day);
  final countByDay = <int, int>{};
  for (final e in entryDates) {
    if (!byId.containsKey(e.plantId)) continue;
    final d = e.date.toLocal();
    final ago =
        todayUtc.difference(DateTime.utc(d.year, d.month, d.day)).inDays;
    if (ago >= 0) countByDay[ago] = (countByDay[ago] ?? 0) + 1;
  }

  bool loggedOn(int ago) => (countByDay[ago] ?? 0) > 0;
  var streak = 0;
  for (var ago = loggedOn(0) ? 0 : 1; loggedOn(ago); ago++) {
    streak++;
  }

  var busiest = 0;
  for (var ago = 0; ago < heatmapDays; ago++) {
    final count = countByDay[ago] ?? 0;
    if (count > busiest) busiest = count;
  }
  int level(int count) =>
      count == 0 ? 0 : (count * heatmapLevels / busiest).ceil();

  return GardenActivity(
    heatmap: [
      for (var ago = heatmapDays - 1; ago >= 0; ago--)
        DayActivity(
          day: DateTime(today.year, today.month, today.day - ago),
          count: countByDay[ago] ?? 0,
          level: level(countByDay[ago] ?? 0),
        ),
    ],
    streakDays: streak,
    days: days,
  );
}
