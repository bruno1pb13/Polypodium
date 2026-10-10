// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pots_dao.dart';

// ignore_for_file: type=lint
mixin _$PotsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocationsTableTable get locationsTable => attachedDatabase.locationsTable;
  $PotsTableTable get potsTable => attachedDatabase.potsTable;
  PotsDaoManager get managers => PotsDaoManager(this);
}

class PotsDaoManager {
  final _$PotsDaoMixin _db;
  PotsDaoManager(this._db);
  $$LocationsTableTableTableManager get locationsTable =>
      $$LocationsTableTableTableManager(
          _db.attachedDatabase, _db.locationsTable);
  $$PotsTableTableTableManager get potsTable =>
      $$PotsTableTableTableManager(_db.attachedDatabase, _db.potsTable);
}
