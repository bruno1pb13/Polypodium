// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_dao.dart';

// ignore_for_file: type=lint
mixin _$SpeciesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  SpeciesDaoManager get managers => SpeciesDaoManager(this);
}

class SpeciesDaoManager {
  final _$SpeciesDaoMixin _db;
  SpeciesDaoManager(this._db);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
}
