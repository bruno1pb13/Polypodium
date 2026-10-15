// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watering_adjustments_dao.dart';

// ignore_for_file: type=lint
mixin _$WateringAdjustmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $WateringAdjustmentsTableTable get wateringAdjustmentsTable =>
      attachedDatabase.wateringAdjustmentsTable;
  WateringAdjustmentsDaoManager get managers =>
      WateringAdjustmentsDaoManager(this);
}

class WateringAdjustmentsDaoManager {
  final _$WateringAdjustmentsDaoMixin _db;
  WateringAdjustmentsDaoManager(this._db);
  $$WateringAdjustmentsTableTableTableManager get wateringAdjustmentsTable =>
      $$WateringAdjustmentsTableTableTableManager(
          _db.attachedDatabase, _db.wateringAdjustmentsTable);
}
