import 'dart:convert';

import 'package:drift/drift.dart';

import '../enums.dart';

class SoilTypeConverter extends TypeConverter<SoilType, String> {
  const SoilTypeConverter();

  @override
  SoilType fromSql(String fromDb) => SoilType.values.byName(fromDb);

  @override
  String toSql(SoilType value) => value.name;
}

class SoilTypeListConverter extends TypeConverter<List<SoilType>, String> {
  const SoilTypeListConverter();

  @override
  List<SoilType> fromSql(String fromDb) {
    final list = (jsonDecode(fromDb) as List<dynamic>).cast<String>();
    return list.map((s) => SoilType.values.byName(s)).toList();
  }

  @override
  String toSql(List<SoilType> value) =>
      jsonEncode(value.map((s) => s.name).toList());
}

class EntryTypeConverter extends TypeConverter<EntryType, String> {
  const EntryTypeConverter();

  @override
  EntryType fromSql(String fromDb) => EntryType.values.byName(fromDb);

  @override
  String toSql(EntryType value) => value.name;
}

class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();

  @override
  SyncStatus fromSql(String fromDb) => SyncStatus.values.byName(fromDb);

  @override
  String toSql(SyncStatus value) => value.name;
}
