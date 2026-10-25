import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../admin/domain/server_watering_settings.dart';

/// One tunable of the weather-adjusted watering as a slider, with its
/// explanation and default. Shared by the server's administration (rules
/// of the whole server) and the local workspace's weather settings.
class WateringRuleSlider extends StatefulWidget {
  const WateringRuleSlider({
    super.key,
    required this.rule,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.defaultValue,
    this.enabled = true,
  });

  final WateringRule rule;
  final double value;
  final double min;
  final double max;
  final double? defaultValue;
  final bool enabled;

  /// Called once the slider is let go on a new value, rounded to its step.
  final Future<void> Function(double value) onChanged;

  @override
  State<WateringRuleSlider> createState() => _WateringRuleSliderState();
}

class _WateringRuleSliderState extends State<WateringRuleSlider> {
  /// The position while dragging, before it is saved.
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rule = widget.rule;
    final step = _step(rule);
    final divisions = ((widget.max - widget.min) / step).round();
    final value =
        (_dragging ?? widget.value).clamp(widget.min, widget.max).toDouble();
    final (title, hint) = switch (rule) {
      WateringRule.minRainMm => (
          l10n.wateringRuleMinRain,
          l10n.wateringRuleMinRainHint
        ),
      WateringRule.rainEfficiency => (
          l10n.wateringRuleRainEfficiency,
          l10n.wateringRuleRainEfficiencyHint
        ),
      WateringRule.maxPostponeDays => (
          l10n.wateringRuleMaxPostpone,
          l10n.wateringRuleMaxPostponeHint
        ),
      WateringRule.maxAdvanceDays => (
          l10n.wateringRuleMaxAdvance,
          l10n.wateringRuleMaxAdvanceHint
        ),
      WateringRule.minDemand => (
          l10n.wateringRuleMinDemand,
          l10n.wateringRuleMinDemandHint
        ),
      WateringRule.maxDemand => (
          l10n.wateringRuleMaxDemand,
          l10n.wateringRuleMaxDemandHint
        ),
    };
    final fallback = widget.defaultValue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.bodyLarge)),
              Text(format(context, rule, value),
                  style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          Text(
            [
              hint,
              if (fallback != null)
                l10n.wateringRuleDefault(format(context, rule, fallback)),
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: value,
            min: widget.min,
            max: widget.max,
            divisions: divisions > 0 ? divisions : null,
            label: format(context, rule, value),
            onChanged: widget.enabled
                ? (v) => setState(() => _dragging = v)
                : null,
            onChangeEnd: widget.enabled ? _save : null,
          ),
        ],
      ),
    );
  }

  Future<void> _save(double v) async {
    try {
      if (v != widget.value) await widget.onChanged(_snap(widget.rule, v));
    } finally {
      if (mounted) setState(() => _dragging = null);
    }
  }

  static double _step(WateringRule rule) => switch (rule) {
        WateringRule.minRainMm => 0.5,
        WateringRule.rainEfficiency || WateringRule.minDemand => 0.05,
        WateringRule.maxDemand => 0.1,
        WateringRule.maxPostponeDays || WateringRule.maxAdvanceDays => 1,
      };

  /// Rounds a slider position to its step, without float noise.
  static double _snap(WateringRule rule, double value) {
    final step = _step(rule);
    return double.parse(((value / step).round() * step).toStringAsFixed(2));
  }

  /// [value] as the rule shows it: millimetres, days or a percentage.
  static String format(BuildContext context, WateringRule rule, double value) {
    final locale = context.l10n.localeName;
    return switch (rule) {
      WateringRule.minRainMm => context.l10n.wateringRuleMm(
          NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1)
              .format(value)),
      WateringRule.maxPostponeDays ||
      WateringRule.maxAdvanceDays =>
        context.l10n.wateringRuleDays(value.round()),
      _ => NumberFormat.percentPattern(locale).format(value),
    };
  }
}
