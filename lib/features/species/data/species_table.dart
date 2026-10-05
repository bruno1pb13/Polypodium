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

  TextColumn get light =>
      text().nullable().map(const LightRequirementConverter())();
  TextColumn get humidity =>
      text().nullable().map(const HumidityLevelConverter())();
  TextColumn get petToxicity => text()
      .map(const PetToxicityConverter())
      .withDefault(const Constant('unknown'))();

  /// Bitmask of flowering months, see [MonthSetConverter].
  IntColumn get floweringMonths => integer()
      .map(const MonthSetConverter())
      .withDefault(const Constant(0))();
  TextColumn get careNotes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
