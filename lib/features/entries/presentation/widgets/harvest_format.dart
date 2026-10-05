import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entry_details.dart';
import '../../domain/entry_model.dart';

/// "1,5 kg", "12 unidades"; just the number when the unit is unknown.
String formatHarvestAmount(
    AppLocalizations l10n, double quantity, HarvestUnit? unit) {
  final formatted = NumberFormat('#,##0.##', l10n.localeName).format(quantity);
  return unit?.amount(l10n, quantity, formatted) ?? formatted;
}

/// Total harvested per unit over [entries], in [HarvestUnit] order, e.g.
/// "1,5 kg · 12 unidades". Harvests without a quantity or a unit are left
/// out; null when nothing is left.
String? harvestTotalsSummary(
    AppLocalizations l10n, Iterable<EntryModel> entries) {
  final totals = <HarvestUnit, double>{};
  for (final e in entries) {
    if (e.type != EntryType.harvest) continue;
    final details = e.details;
    if (details is! HarvestDetails) continue;
    final (quantity, unit) = (details.quantity, details.unit);
    if (quantity == null || unit == null) continue;
    totals[unit] = (totals[unit] ?? 0) + quantity;
  }
  if (totals.isEmpty) return null;
  return [
    for (final unit in HarvestUnit.values)
      if (totals[unit] case final total?)
        formatHarvestAmount(l10n, total, unit),
  ].join(' · ');
}
