import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';
import '../../locations/data/locations_table.dart';

/// Containers plants live in: pots, planters, beds. A plant is in at most
/// one pot (`plants.potId`); a pot holds any number of plants.
///
/// Synced as the entity type `bed` (see DriftSyncStorageAdapter): the app
/// calls them pots, but the server has stored `bed` rows since its first
/// per-entity tables, so the historical wire name is kept.
class PotsTable extends Table {
  @override
  String get tableName => 'pots';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind =>
      text().map(const PotKindConverter()).withDefault(const Constant('pot'))();
  RealColumn get diameterCm => real().nullable()();
  TextColumn get material =>
      text().map(const PotMaterialConverter()).nullable()();
  TextColumn get locationId => text()
      .nullable()
      .references(LocationsTable, #id, onDelete: KeyAction.setNull)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
