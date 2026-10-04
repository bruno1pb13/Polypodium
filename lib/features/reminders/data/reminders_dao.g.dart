// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminders_dao.dart';

// ignore_for_file: type=lint
mixin _$RemindersDaoMixin on DatabaseAccessor<AppDatabase> {
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SoilsTableTable get soilsTable => attachedDatabase.soilsTable;
  $LocationsTableTable get locationsTable => attachedDatabase.locationsTable;
  $PlantsTableTable get plantsTable => attachedDatabase.plantsTable;
  $RemindersTableTable get remindersTable => attachedDatabase.remindersTable;
  $EntriesTableTable get entriesTable => attachedDatabase.entriesTable;
  RemindersDaoManager get managers => RemindersDaoManager(this);
}

class RemindersDaoManager {
  final _$RemindersDaoMixin _db;
  RemindersDaoManager(this._db);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$SoilsTableTableTableManager get soilsTable =>
      $$SoilsTableTableTableManager(_db.attachedDatabase, _db.soilsTable);
  $$LocationsTableTableTableManager get locationsTable =>
      $$LocationsTableTableTableManager(
          _db.attachedDatabase, _db.locationsTable);
  $$PlantsTableTableTableManager get plantsTable =>
      $$PlantsTableTableTableManager(_db.attachedDatabase, _db.plantsTable);
  $$RemindersTableTableTableManager get remindersTable =>
      $$RemindersTableTableTableManager(
          _db.attachedDatabase, _db.remindersTable);
  $$EntriesTableTableTableManager get entriesTable =>
      $$EntriesTableTableTableManager(_db.attachedDatabase, _db.entriesTable);
}
