// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_photos_dao.dart';

// ignore_for_file: type=lint
mixin _$EntryPhotosDaoMixin on DatabaseAccessor<AppDatabase> {
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SoilsTableTable get soilsTable => attachedDatabase.soilsTable;
  $LocationsTableTable get locationsTable => attachedDatabase.locationsTable;
  $PlantsTableTable get plantsTable => attachedDatabase.plantsTable;
  $EntriesTableTable get entriesTable => attachedDatabase.entriesTable;
  $EntryPhotosTableTable get entryPhotosTable =>
      attachedDatabase.entryPhotosTable;
  EntryPhotosDaoManager get managers => EntryPhotosDaoManager(this);
}

class EntryPhotosDaoManager {
  final _$EntryPhotosDaoMixin _db;
  EntryPhotosDaoManager(this._db);
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
  $$EntryPhotosTableTableTableManager get entryPhotosTable =>
      $$EntryPhotosTableTableTableManager(
          _db.attachedDatabase, _db.entryPhotosTable);
}
