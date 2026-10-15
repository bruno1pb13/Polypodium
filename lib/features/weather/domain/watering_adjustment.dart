/// Why the server moved a plant's watering (`reason` in
/// `GET /api/v1/weather/watering`).
enum WateringAdjustmentReason {
  /// Rain fell since the last watering, or is forecast.
  rain,

  /// Cooler days than usual: the plant uses less water.
  cool,

  /// Hotter, drier days than usual: the plant uses more water.
  heat,

  none;

  static WateringAdjustmentReason parse(String? name) =>
      values.where((r) => r.name == name).firstOrNull ?? none;
}

/// How many days the weather moves one plant's next watering, as last
/// computed by the server. Stored locally (not synced) so the schedule,
/// agenda and notifications keep it offline.
///
/// It was computed for one watering cycle: [lastWateredAt] and
/// [frequencyDays] are what the server used, and [appliesTo] stops
/// applying it once the plant is watered again or its interval changes.
class WateringAdjustment {
  const WateringAdjustment({
    required this.plantId,
    required this.lastWateredAt,
    required this.frequencyDays,
    required this.shiftDays,
    required this.reason,
    required this.fetchedAt,
    this.rainMm = 0,
  });

  /// After this long without a fresh fetch, the forecast behind an
  /// adjustment is too old to trust.
  static const maxAge = Duration(days: 3);

  final String plantId;
  final DateTime lastWateredAt;
  final int frequencyDays;

  /// Positive = postponed, negative = brought forward.
  final int shiftDays;
  final WateringAdjustmentReason reason;

  /// Rain counted for a postponement (mm).
  final double rainMm;

  /// When this device got it from the server.
  final DateTime fetchedAt;

  /// Whether it still describes the plant's current cycle: same last
  /// watering (to the minute, since stored dates may lose milliseconds),
  /// same interval, and fetched recently.
  bool appliesTo({
    required DateTime? lastIrrigatedAt,
    required int? frequencyDays,
    DateTime? now,
  }) {
    if (shiftDays == 0 || lastIrrigatedAt == null) return false;
    if (frequencyDays != this.frequencyDays) return false;
    if (lastIrrigatedAt.difference(lastWateredAt).abs() >=
        const Duration(minutes: 1)) {
      return false;
    }
    return (now ?? DateTime.now()).difference(fetchedAt) < maxAge;
  }

  /// One plant of the server's response, or null when it is malformed.
  static WateringAdjustment? fromJson(Map<String, dynamic> json,
      {required DateTime fetchedAt}) {
    final plantId = json['plantId'];
    final last = DateTime.tryParse(json['lastWateredAt'] as String? ?? '');
    final frequency = json['frequencyDays'];
    final shift = json['shiftDays'];
    if (plantId is! String || last == null || frequency is! int) return null;
    if (shift is! int) return null;
    return WateringAdjustment(
      plantId: plantId,
      lastWateredAt: last,
      frequencyDays: frequency,
      shiftDays: shift,
      reason: WateringAdjustmentReason.parse(json['reason'] as String?),
      rainMm: (json['rainMm'] as num?)?.toDouble() ?? 0,
      fetchedAt: fetchedAt,
    );
  }
}
