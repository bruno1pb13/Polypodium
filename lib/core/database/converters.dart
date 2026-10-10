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

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class PlantStatusConverter extends TypeConverter<PlantStatus, String> {
  const PlantStatusConverter();

  @override
  PlantStatus fromSql(String fromDb) => PlantStatus.fromName(fromDb);

  @override
  String toSql(PlantStatus value) => value.name;
}

class EntryTypeConverter extends TypeConverter<EntryType, String> {
  const EntryTypeConverter();

  @override
  // Unknown names never reach the table (sync and backup import skip them),
  // but a bad row must not break every query of its plant.
  EntryType fromSql(String fromDb) =>
      EntryType.fromName(fromDb) ?? EntryType.other;

  @override
  String toSql(EntryType value) => value.name;
}

class LightRequirementConverter
    extends TypeConverter<LightRequirement?, String?> {
  const LightRequirementConverter();

  @override
  LightRequirement? fromSql(String? fromDb) =>
      LightRequirement.fromName(fromDb);

  @override
  String? toSql(LightRequirement? value) => value?.name;
}

class HumidityLevelConverter extends TypeConverter<HumidityLevel?, String?> {
  const HumidityLevelConverter();

  @override
  HumidityLevel? fromSql(String? fromDb) => HumidityLevel.fromName(fromDb);

  @override
  String? toSql(HumidityLevel? value) => value?.name;
}

class PetToxicityConverter extends TypeConverter<PetToxicity, String> {
  const PetToxicityConverter();

  @override
  PetToxicity fromSql(String fromDb) => PetToxicity.fromName(fromDb);

  @override
  String toSql(PetToxicity value) => value.name;
}

/// A set of months (1–12) as a bitmask, bit `m - 1` set for month `m`. Sync
/// payloads and backups carry the months as a plain list instead
/// ([toJson]/[fromJson]).
class MonthSetConverter extends TypeConverter<Set<int>, int> {
  const MonthSetConverter();

  @override
  Set<int> fromSql(int fromDb) => {
        for (var m = 1; m <= 12; m++)
          if (fromDb & (1 << (m - 1)) != 0) m,
      };

  @override
  int toSql(Set<int> value) => value
      .where((m) => m >= 1 && m <= 12)
      .fold(0, (mask, m) => mask | (1 << (m - 1)));

  static List<int> toJson(Set<int> months) => months.toList()..sort();

  /// Missing (older payloads) or invalid entries are dropped.
  static Set<int> fromJson(Object? json) => json is List
      ? {
          for (final m in json)
            if (m is int && m >= 1 && m <= 12) m,
        }
      : {};
}

class PotKindConverter extends TypeConverter<PotKind, String> {
  const PotKindConverter();

  @override
  PotKind fromSql(String fromDb) => PotKind.fromName(fromDb);

  @override
  String toSql(PotKind value) => value.name;
}

class PotMaterialConverter extends TypeConverter<PotMaterial?, String?> {
  const PotMaterialConverter();

  @override
  PotMaterial? fromSql(String? fromDb) => PotMaterial.fromName(fromDb);

  @override
  String? toSql(PotMaterial? value) => value?.name;
}
