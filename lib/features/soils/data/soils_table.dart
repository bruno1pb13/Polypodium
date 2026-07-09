import 'package:drift/drift.dart';

class SoilsTable extends Table {
  @override
  String get tableName => 'soils';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get composition => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get imageSource => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();

  /// True for the default soils seeded on database creation/upgrade (see
  /// app_database.dart), false for soils the user created. Distinguishes
  /// "never touched by the user" from "genuinely local-only data worth
  /// migrating" in WorkspaceMigrationService, now that there's no
  /// syncStatus column to repurpose for that check.
  BoolColumn get isSeeded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
