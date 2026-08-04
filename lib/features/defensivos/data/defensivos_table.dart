import 'package:drift/drift.dart';

class DefensivosTable extends Table {
  @override
  String get tableName => 'defensivos';

  TextColumn get id => text()();
  TextColumn get name => text()();
  /// Stores a [DefensivoCategory] name, or null.
  TextColumn get category => text().nullable()();

  /// Only meaningful when [category] is [DefensivoCategory.custom] — the
  /// free-text label the user typed for their own category.
  TextColumn get customCategoryLabel => text().nullable()();

  /// Composition + application instructions.
  TextColumn get composition => text().nullable()();
  IntColumn get carenciaDays => integer().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get imageSource => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
