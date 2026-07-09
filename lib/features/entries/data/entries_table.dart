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
  // Numeric measurement: height in cm, chlorosis severity (1–3), etc.
  RealColumn get numericValue => real().nullable()();
  // JSON blob for extra structured data (e.g. {"pestType":"Cochonilha"})
  TextColumn get extraData => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
