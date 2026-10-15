import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/watering_adjustment.dart';

/// Emoji, short label ("Watering postponed 2 days for rain") and detail of
/// a weather adjustment, for the plant screen and the agenda.
({String emoji, String label, String detail}) wateringAdjustmentText(
    AppLocalizations l10n, WateringAdjustment adjustment) {
  final days = adjustment.shiftDays.abs();
  return switch (adjustment.reason) {
    WateringAdjustmentReason.heat => (
        emoji: '☀️',
        label: l10n.wateringAdvancedHeat(days),
        detail: l10n.wateringHeatDetail,
      ),
    WateringAdjustmentReason.cool => (
        emoji: '🌥️',
        label: l10n.wateringPostponedCool(days),
        detail: l10n.wateringCoolDetail,
      ),
    // A postponement is rain or cool weather; an unknown reason with a
    // shift comes from a newer server, labelled by direction.
    _ when adjustment.shiftDays < 0 => (
        emoji: '☀️',
        label: l10n.wateringAdvancedHeat(days),
        detail: l10n.wateringHeatDetail,
      ),
    _ => (
        emoji: '🌧️',
        label: l10n.wateringPostponedRain(days),
        detail: l10n.wateringRainDetail(
            NumberFormat.decimalPatternDigits(
                    locale: l10n.localeName, decimalDigits: 0)
                .format(adjustment.rainMm)),
      ),
  };
}
