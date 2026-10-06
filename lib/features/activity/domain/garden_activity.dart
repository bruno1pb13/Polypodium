import '../../../core/enums.dart';
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

/// An entry together with the plant it belongs to.
typedef ActivityEntry = ({EntryModel entry, PlantWithSpecies plant});

/// The entries of one calendar day, newest first.
typedef ActivityDay = ({DateTime day, List<ActivityEntry> entries});

/// The garden's logging history: a per-day chart of the last [chartDays]
/// days, the streak and every entry grouped by day.
class GardenActivity {
  /// One item per day of the last [chartDays] days, oldest first; the last
  /// one is today.
  final List<DayActivity> chart;

  /// Consecutive days with at least one entry, ending today (or yesterday,
  /// while nothing was logged today yet).
  final int streakDays;

  /// Days with entries, newest first.
  final List<ActivityDay> days;

  const GardenActivity({
    required this.chart,
    required this.streakDays,
    required this.days,
  });
}

/// How many days the activity chart shows.
const chartDays = 14;

/// How far back the activity screen loads entries. Every range covers the
/// chart's [chartDays].
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

/// Builds the activity of [plants] from [entries] (every plant's, newest
/// first). Entries of plants not in [plants] are left out.
GardenActivity buildGardenActivity({
  required List<PlantWithSpecies> plants,
  required List<EntryModel> entries,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);
  final byId = {for (final p in plants) p.plant.id: p};

  final irrigationByDay = <int, int>{};
  final careByDay = <int, int>{};
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

    final ago = today.difference(day).inDays;
    if (ago < 0) continue;
    final bucket = e.type == EntryType.irrigation ? irrigationByDay : careByDay;
    bucket[ago] = (bucket[ago] ?? 0) + 1;
  }

  bool loggedOn(int ago) =>
      (irrigationByDay[ago] ?? 0) + (careByDay[ago] ?? 0) > 0;
  var streak = 0;
  for (var ago = loggedOn(0) ? 0 : 1; loggedOn(ago); ago++) {
    streak++;
  }

  return GardenActivity(
    chart: [
      for (var ago = chartDays - 1; ago >= 0; ago--)
        DayActivity(
          day: DateTime(today.year, today.month, today.day - ago),
          irrigation: irrigationByDay[ago] ?? 0,
          care: careByDay[ago] ?? 0,
        ),
    ],
    streakDays: streak,
    days: days,
  );
}
