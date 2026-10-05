import 'package:drift/drift.dart';

import '../../../core/database/converters.dart';
import '../../locations/data/locations_table.dart';
import '../../soils/data/soils_table.dart';
import '../../species/data/species_table.dart';

class PlantsTable extends Table {
  @override
  String get tableName => 'plants';

  TextColumn get id => text()();
  TextColumn get speciesId =>
      text().references(SpeciesTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get nickname => text()();
  TextColumn get soilType => text().references(SoilsTable, #id)();

  /// Null means: inherit from species.defaultIrrigationFrequencyDays
  IntColumn get irrigationFrequencyDays => integer().nullable()();

  DateTimeColumn get acquisitionDate => dateTime()();
  TextColumn get locationId => text()
      .nullable()
      .references(LocationsTable, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get lastIrrigatedAt => dateTime().nullable()();

  /// Derived from the most recent 'pesticide' entry — always recomputed by
  /// PlantsRepository.refreshPesticideStatus, never user-editable.
  DateTimeColumn get lastPesticideAppliedAt => dateTime().nullable()();

  /// Recurrence (in days) set on the most recent 'pesticide' entry, or null
  /// if that entry didn't request a reminder.
  IntColumn get pesticideReapplicationDays => integer().nullable()();

  /// Lifecycle status — only `active` plants get reminders and show up in
  /// the default lists; the others keep their diary as history.
  TextColumn get status => text()
      .map(const PlantStatusConverter())
      .withDefault(const Constant('active'))();
  DateTimeColumn get statusChangedAt => dateTime().nullable()();

  /// The plant this one was propagated from (a cutting/division), if any.
  /// Plants are only soft-deleted, so a removed parent keeps its id here.
  TextColumn get parentPlantId => text()
      .nullable()
      .references(PlantsTable, #id, onDelete: KeyAction.setNull)();

  /// Photo picked as the plant's cover: the id of an entry (its main photo)
  /// or of an entry_photos row. Ids, not paths, since each device stores a
  /// synced photo under its own path. Null, or pointing at a photo that was
  /// deleted, means the latest photo is used.
  TextColumn get coverPhotoId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
