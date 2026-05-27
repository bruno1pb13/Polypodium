import 'package:drift/drift.dart';
import '../../../core/database/converters.dart';

class SoilsTable extends Table {
  @override
  String get tableName => 'soils';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get composition => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
