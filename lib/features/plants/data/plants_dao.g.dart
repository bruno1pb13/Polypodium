// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plants_dao.dart';

// ignore_for_file: type=lint
mixin _$PlantsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SoilsTableTable get soilsTable => attachedDatabase.soilsTable;
  $LocationsTableTable get locationsTable => attachedDatabase.locationsTable;
  $PlantsTableTable get plantsTable => attachedDatabase.plantsTable;
  PlantsDaoManager get managers => PlantsDaoManager(this);
}

class PlantsDaoManager {
  final _$PlantsDaoMixin _db;
  PlantsDaoManager(this._db);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$SoilsTableTableTableManager get soilsTable =>
      $$SoilsTableTableTableManager(_db.attachedDatabase, _db.soilsTable);
  $$LocationsTableTableTableManager get locationsTable =>
      $$LocationsTableTableTableManager(
          _db.attachedDatabase, _db.locationsTable);
  $$PlantsTableTableTableManager get plantsTable =>
      $$PlantsTableTableTableManager(_db.attachedDatabase, _db.plantsTable);
}
