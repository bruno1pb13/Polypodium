import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/watering_adjustment.dart';

part 'watering_adjustments_dao.g.dart';

@DriftAccessor(tables: [WateringAdjustmentsTable])
class WateringAdjustmentsDao extends DatabaseAccessor<AppDatabase>
    with _$WateringAdjustmentsDaoMixin {
  WateringAdjustmentsDao(super.db);

  /// Every stored adjustment by plant id.
  Future<Map<String, WateringAdjustment>> getAll() async => {
        for (final row in await select(wateringAdjustmentsTable).get())
          row.plantId: _fromRow(row),
      };

  Stream<Map<String, WateringAdjustment>> watchAll() =>
      select(wateringAdjustmentsTable).watch().map((rows) => {
            for (final row in rows) row.plantId: _fromRow(row),
          });

  /// Swaps the table's contents for [adjustments] (empty clears it).
  /// Returns whether a schedule may have changed: some adjustment before or
  /// after actually moves a date.
  Future<bool> replaceAll(List<WateringAdjustment> adjustments) =>
      transaction(() async {
        final before = await getAll();
        await delete(wateringAdjustmentsTable).go();
        await batch((b) => b.insertAll(wateringAdjustmentsTable, [
              for (final a in adjustments)
                WateringAdjustmentsTableCompanion.insert(
                  plantId: a.plantId,
                  lastWateredAt: a.lastWateredAt,
                  frequencyDays: a.frequencyDays,
                  shiftDays: a.shiftDays,
                  reason: a.reason.name,
                  rainMm: Value(a.rainMm),
                  fetchedAt: a.fetchedAt,
                ),
            ]));
        return before.values.any((a) => a.shiftDays != 0) ||
            adjustments.any((a) => a.shiftDays != 0);
      });

  static WateringAdjustment _fromRow(WateringAdjustmentsTableData row) =>
      WateringAdjustment(
        plantId: row.plantId,
        lastWateredAt: row.lastWateredAt,
        frequencyDays: row.frequencyDays,
        shiftDays: row.shiftDays,
        reason: WateringAdjustmentReason.parse(row.reason),
        rainMm: row.rainMm,
        fetchedAt: row.fetchedAt,
      );
}
