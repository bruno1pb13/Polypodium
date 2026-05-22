import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';
import '../../locations/data/locations_table.dart';
import '../../species/data/species_table.dart';

class PlantsTable extends Table {
  @override
  String get tableName => 'plants';

  TextColumn get id => text()();
  TextColumn get speciesId =>
      text().references(SpeciesTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get nickname => text()();
  TextColumn get soilType => text().map(const SoilTypeConverter())();

  /// Null means: inherit from species.defaultIrrigationFrequencyDays
  IntColumn get irrigationFrequencyDays => integer().nullable()();

  DateTimeColumn get acquisitionDate => dateTime()();
  TextColumn get location => text().nullable()();
  TextColumn get locationId => text()
      .nullable()
      .references(LocationsTable, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get lastIrrigatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  // TODO(sync): Pending/synced/conflict status for future server sync
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
