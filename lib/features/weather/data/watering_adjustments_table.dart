import 'package:drift/drift.dart';

/// The server's latest weather adjustment per plant (see
/// WateringAdjustment). Local to the device and never synced: each device
/// fetches it from its workspace's server and replaces the whole table.
class WateringAdjustmentsTable extends Table {
  @override
  String get tableName => 'watering_adjustments';

  TextColumn get plantId => text()();
  DateTimeColumn get lastWateredAt => dateTime()();
  IntColumn get frequencyDays => integer()();
  IntColumn get shiftDays => integer()();
  TextColumn get reason => text()();
  RealColumn get rainMm => real().withDefault(const Constant(0))();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {plantId};
}
