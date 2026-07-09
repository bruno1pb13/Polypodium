import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';

class SpeciesTable extends Table {
  @override
  String get tableName => 'species';

  TextColumn get id => text()();
  TextColumn get scientificName => text()();
  TextColumn get popularName => text()();
  IntColumn get defaultIrrigationFrequencyDays => integer().nullable()();

  /// JSON-encoded list of soil IDs
  TextColumn get recommendedSoilTypes =>
      text().map(const StringListConverter())();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
