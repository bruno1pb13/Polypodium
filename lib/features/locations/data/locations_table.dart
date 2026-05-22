import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';

class LocationsTable extends Table {
  @override
  String get tableName => 'locations';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
