import 'package:flutter/foundation.dart';

import '../../../core/enums.dart';
import '../../../core/utils/date_utils.dart';
import '../../defensivos/domain/defensivo_model.dart';
import 'entry_details.dart';
import 'entry_model.dart';

/// The plant must not be harvested up to and including [until]: a defensivo
/// applied on day D with a carência of N days covers D … D+N-1, so harvest is
/// allowed again N calendar days after the application.
class CarenciaStatus {
  /// Last day of the carência, at local midnight.
  final DateTime until;

  /// Names of the applied products whose carência covers the checked day.
  final List<String> productNames;

  const CarenciaStatus({required this.until, required this.productNames});

  @override
  bool operator ==(Object other) =>
      other is CarenciaStatus &&
      other.until == until &&
      listEquals(other.productNames, productNames);

  @override
  int get hashCode => Object.hash(until, Object.hashAll(productNames));

  @override
  String toString() => 'CarenciaStatus($until, $productNames)';
}

/// Carência in days of each catalog defensivo that has one; deleted
/// defensivos are left out.
Map<String, int> carenciaDaysByDefensivo(Iterable<DefensivoModel> defensivos) =>
    {
      for (final d in defensivos)
        if (d.deletedAt == null && d.carenciaDays != null)
          d.id: d.carenciaDays!,
    };

/// Carência status of a plant on [day], from its [entries] (only pesticide
/// entries that aren't deleted count). Each product uses the carência copied
/// into the entry when it was saved, or else the current catalog value in
/// [catalogDays]; a product with neither, or with 0 days, is ignored.
/// Applications after [day] don't count. Null when [day] is outside every
/// carência.
CarenciaStatus? carenciaOn(
  DateTime day,
  Iterable<EntryModel> entries,
  Map<String, int> catalogDays,
) {
  DateTime? until;
  final names = <String>[];
  for (final entry in entries) {
    if (entry.type != EntryType.pesticide || entry.deletedAt != null) continue;
    final details = entry.details;
    if (details is! PesticideDetails) continue;
    final elapsed = calendarDaysBetween(entry.date, day);
    if (elapsed < 0) continue;
    for (final product in details.products) {
      final days = product.carenciaDays ?? catalogDays[product.defensivoId];
      if (days == null || elapsed >= days) continue;
      final applied = entry.date.toLocal();
      final end = DateTime(applied.year, applied.month, applied.day + days - 1);
      if (until == null || end.isAfter(until)) until = end;
      if (product.name.isNotEmpty && !names.contains(product.name)) {
        names.add(product.name);
      }
    }
  }
  return until == null
      ? null
      : CarenciaStatus(until: until, productNames: names);
}
