import 'dart:convert';

import 'package:polypodium_core/weather.dart' as shared;

import '../../admin/domain/server_watering_settings.dart';

/// The rules the local workspace's weather advice uses, tuned on this
/// device. Like the server's settings, only the values the user changed
/// are stored, so the rest follow the built-in defaults of
/// polypodium_core.
class LocalWateringRules {
  const LocalWateringRules([this.overrides = const {}]);

  final Map<WateringRule, double> overrides;

  static const _builtIn = shared.WateringRules();

  /// The same ranges the server accepts (watering_settings.dart there).
  static const limits = <WateringRule, ({double min, double max})>{
    WateringRule.minRainMm: (min: 0, max: 50),
    WateringRule.rainEfficiency: (min: 0, max: 1),
    WateringRule.maxPostponeDays: (min: 0, max: 30),
    WateringRule.maxAdvanceDays: (min: 0, max: 30),
    WateringRule.minDemand: (min: 0.1, max: 1),
    WateringRule.maxDemand: (min: 1, max: 5),
  };

  static double defaultOf(WateringRule rule) => switch (rule) {
        WateringRule.minRainMm => _builtIn.minRainMm,
        WateringRule.rainEfficiency => _builtIn.rainEfficiency,
        WateringRule.maxPostponeDays => _builtIn.maxPostponeDays.toDouble(),
        WateringRule.maxAdvanceDays => _builtIn.maxAdvanceDays.toDouble(),
        WateringRule.minDemand => _builtIn.minDemand,
        WateringRule.maxDemand => _builtIn.maxDemand,
      };

  double value(WateringRule rule) => overrides[rule] ?? defaultOf(rule);

  bool get isDefault => WateringRule.values
      .every((r) => value(r) == defaultOf(r));

  /// A copy with [rule] set to [value]; a value equal to the default is
  /// dropped, so it keeps following the default.
  LocalWateringRules withRule(WateringRule rule, double value) {
    final limit = limits[rule]!;
    final clamped = value.clamp(limit.min, limit.max).toDouble();
    return LocalWateringRules({
      for (final e in overrides.entries)
        if (e.key != rule) e.key: e.value,
      if (clamped != defaultOf(rule)) rule: clamped,
    });
  }

  shared.WateringRules toRules() => shared.WateringRules(
        minRainMm: value(WateringRule.minRainMm),
        rainEfficiency: value(WateringRule.rainEfficiency),
        maxPostponeDays: value(WateringRule.maxPostponeDays).round(),
        maxAdvanceDays: value(WateringRule.maxAdvanceDays).round(),
        minDemand: value(WateringRule.minDemand),
        maxDemand: value(WateringRule.maxDemand),
        fallbackEt0: _builtIn.fallbackEt0,
      );

  String toJson() =>
      jsonEncode({for (final e in overrides.entries) e.key.name: e.value});

  /// Unknown names and values out of range are ignored, so a broken or
  /// older setting falls back to the defaults.
  factory LocalWateringRules.fromJson(String? json) {
    if (json == null) return const LocalWateringRules();
    Object? raw;
    try {
      raw = jsonDecode(json);
    } on FormatException {
      return const LocalWateringRules();
    }
    if (raw is! Map) return const LocalWateringRules();
    return LocalWateringRules({
      for (final rule in WateringRule.values)
        if (raw[rule.name] case final num v
            when v >= limits[rule]!.min && v <= limits[rule]!.max)
          rule: v.toDouble(),
    });
  }
}
