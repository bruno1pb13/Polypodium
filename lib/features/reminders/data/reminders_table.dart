import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';
import '../../plants/data/plants_table.dart';

/// User-configured recurring care reminders (fertilizing, pruning, ...).
/// When the care was last done is not stored: it is derived from the plant's
/// most recent entry of [entryType].
class RemindersTable extends Table {
  @override
  String get tableName => 'reminders';

  TextColumn get id => text()();
  TextColumn get plantId =>
      text().references(PlantsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryType => text().map(const EntryTypeConverter())();
  IntColumn get intervalDays => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
