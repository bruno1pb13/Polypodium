/// One tunable of the server's weather-adjusted watering
/// (`GET /api/v1/admin/watering`).
enum WateringRule {
  /// Daily rain below this (mm) is ignored.
  minRainMm,

  /// Share of the rain that reaches the roots (0–1).
  rainEfficiency,

  /// The most a watering is postponed, in days.
  maxPostponeDays,

  /// The most a watering is brought forward, in days.
  maxAdvanceDays,

  /// The least a mild day uses, in typical days (0.1–1).
  minDemand,

  /// The most a hot day uses, in typical days (1–5).
  maxDemand;

  bool get isWholeDays => this == maxPostponeDays || this == maxAdvanceDays;
}

/// The server-wide rules that move watering dates with the weather, as an
/// admin sees them. [values], [defaults] and [limits] come from the server,
/// so a rule a newer server bounds differently still fits its slider.
class ServerWateringSettings {
  const ServerWateringSettings({
    required this.enabled,
    required this.values,
    required this.defaults,
    required this.limits,
  });

  final bool enabled;
  final Map<WateringRule, double> values;
  final Map<WateringRule, double> defaults;
  final Map<WateringRule, ({double min, double max})> limits;

  double value(WateringRule rule) => values[rule] ?? defaults[rule] ?? 0;

  bool get isDefault => WateringRule.values
      .every((r) => defaults[r] == null || value(r) == defaults[r]);

  factory ServerWateringSettings.fromJson(Map<String, dynamic> json) {
    Map<WateringRule, double> numbers(Object? raw) => {
          if (raw is Map)
            for (final rule in WateringRule.values)
              if (raw[rule.name] case final num v) rule: v.toDouble(),
        };
    final limits = json['limits'];
    return ServerWateringSettings(
      enabled: json['enabled'] as bool? ?? true,
      values: numbers(json),
      defaults: numbers(json['defaults']),
      limits: {
        if (limits is Map)
          for (final rule in WateringRule.values)
            if (limits[rule.name]
                case {'min': final num min, 'max': final num max})
              rule: (min: min.toDouble(), max: max.toDouble()),
      },
    );
  }
}
