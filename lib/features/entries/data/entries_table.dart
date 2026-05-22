import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';
import '../../plants/data/plants_table.dart';

class EntriesTable extends Table {
  @override
  String get tableName => 'entries';

  TextColumn get id => text()();
  TextColumn get plantId =>
      text().references(PlantsTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get type => text().map(const EntryTypeConverter())();
  DateTimeColumn get createdAt => dateTime()();

  // TODO(sync): Pending/synced/conflict status for future server sync
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
