// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defensivos_dao.dart';

// ignore_for_file: type=lint
mixin _$DefensivosDaoMixin on DatabaseAccessor<AppDatabase> {
  $DefensivosTableTable get defensivosTable => attachedDatabase.defensivosTable;
  DefensivosDaoManager get managers => DefensivosDaoManager(this);
}

class DefensivosDaoManager {
  final _$DefensivosDaoMixin _db;
  DefensivosDaoManager(this._db);
  $$DefensivosTableTableTableManager get defensivosTable =>
      $$DefensivosTableTableTableManager(
          _db.attachedDatabase, _db.defensivosTable);
}
