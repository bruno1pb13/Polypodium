enum Season { spring, summer, autumn, winter }

/// The season a place is in on a given date, and when the next one starts.
class SeasonInfo {
  const SeasonInfo({
    required this.current,
    required this.next,
    required this.daysUntilNext,
  });

  final Season current;
  final Season next;
  final int daysUntilNext;
}

/// Approximate equinox/solstice dates (they drift by a day or so between
/// years), as (month, day, season starting then in the northern hemisphere).
const _northernStarts = [
  (3, 20, Season.spring),
  (6, 21, Season.summer),
  (9, 22, Season.autumn),
  (12, 21, Season.winter),
];

Season _opposite(Season s) => switch (s) {
      Season.spring => Season.autumn,
      Season.summer => Season.winter,
      Season.autumn => Season.spring,
      Season.winter => Season.summer,
    };

/// Astronomical season at [latitude] on [date]: south of the equator the
/// seasons are inverted (spring starts in September).
SeasonInfo seasonAt(DateTime date, double latitude) {
  final day = DateTime.utc(date.year, date.month, date.day);
  final southern = latitude < 0;
  Season adjust(Season s) => southern ? _opposite(s) : s;

  // Season boundaries from last December to next March cover every date.
  final boundaries = [
    for (final year in [day.year - 1, day.year, day.year + 1])
      for (final (month, d, season) in _northernStarts)
        (DateTime.utc(year, month, d), adjust(season)),
  ];
  var current = boundaries.first.$2;
  for (final (start, season) in boundaries) {
    if (start.isAfter(day)) {
      return SeasonInfo(
        current: current,
        next: season,
        daysUntilNext: start.difference(day).inDays,
      );
    }
    current = season;
  }
  throw StateError('unreachable');
}
