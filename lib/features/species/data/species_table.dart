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

  // TODO(sync): Pending/synced/conflict status for future server sync
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('pending'))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
