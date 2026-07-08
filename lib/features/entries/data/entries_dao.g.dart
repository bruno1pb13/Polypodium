// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entries_dao.dart';

// ignore_for_file: type=lint
mixin _$EntriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SoilsTableTable get soilsTable => attachedDatabase.soilsTable;
  $LocationsTableTable get locationsTable => attachedDatabase.locationsTable;
  $PlantsTableTable get plantsTable => attachedDatabase.plantsTable;
  $EntriesTableTable get entriesTable => attachedDatabase.entriesTable;
  EntriesDaoManager get managers => EntriesDaoManager(this);
}

class EntriesDaoManager {
  final _$EntriesDaoMixin _db;
  EntriesDaoManager(this._db);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$SoilsTableTableTableManager get soilsTable =>
      $$SoilsTableTableTableManager(_db.attachedDatabase, _db.soilsTable);
  $$LocationsTableTableTableManager get locationsTable =>
      $$LocationsTableTableTableManager(
          _db.attachedDatabase, _db.locationsTable);
  $$PlantsTableTableTableManager get plantsTable =>
      $$PlantsTableTableTableManager(_db.attachedDatabase, _db.plantsTable);
  $$EntriesTableTableTableManager get entriesTable =>
      $$EntriesTableTableTableManager(_db.attachedDatabase, _db.entriesTable);
}
