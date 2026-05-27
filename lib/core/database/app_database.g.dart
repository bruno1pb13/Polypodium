// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SpeciesTableTable extends SpeciesTable
    with TableInfo<$SpeciesTableTable, SpeciesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scientificNameMeta =
      const VerificationMeta('scientificName');
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
      'scientific_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _popularNameMeta =
      const VerificationMeta('popularName');
  @override
  late final GeneratedColumn<String> popularName = GeneratedColumn<String>(
      'popular_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultIrrigationFrequencyDaysMeta =
      const VerificationMeta('defaultIrrigationFrequencyDays');
  @override
  late final GeneratedColumn<int> defaultIrrigationFrequencyDays =
      GeneratedColumn<int>(
          'default_irrigation_frequency_days', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      recommendedSoilTypes = GeneratedColumn<String>(
              'recommended_soil_types', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>(
              $SpeciesTableTable.$converterrecommendedSoilTypes);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<SyncStatus>($SpeciesTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scientificName,
        popularName,
        defaultIrrigationFrequencyDays,
        recommendedSoilTypes,
        syncStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species';
  @override
  VerificationContext validateIntegrity(Insertable<SpeciesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
          _scientificNameMeta,
          scientificName.isAcceptableOrUnknown(
              data['scientific_name']!, _scientificNameMeta));
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('popular_name')) {
      context.handle(
          _popularNameMeta,
          popularName.isAcceptableOrUnknown(
              data['popular_name']!, _popularNameMeta));
    } else if (isInserting) {
      context.missing(_popularNameMeta);
    }
    if (data.containsKey('default_irrigation_frequency_days')) {
      context.handle(
          _defaultIrrigationFrequencyDaysMeta,
          defaultIrrigationFrequencyDays.isAcceptableOrUnknown(
              data['default_irrigation_frequency_days']!,
              _defaultIrrigationFrequencyDaysMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      scientificName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scientific_name'])!,
      popularName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}popular_name'])!,
      defaultIrrigationFrequencyDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}default_irrigation_frequency_days']),
      recommendedSoilTypes: $SpeciesTableTable.$converterrecommendedSoilTypes
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}recommended_soil_types'])!),
      syncStatus: $SpeciesTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SpeciesTableTable createAlias(String alias) {
    return $SpeciesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterrecommendedSoilTypes =
      const StringListConverter();
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class SpeciesTableData extends DataClass
    implements Insertable<SpeciesTableData> {
  final String id;
  final String scientificName;
  final String popularName;
  final int? defaultIrrigationFrequencyDays;

  /// JSON-encoded list of soil IDs
  final List<String> recommendedSoilTypes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  const SpeciesTableData(
      {required this.id,
      required this.scientificName,
      required this.popularName,
      this.defaultIrrigationFrequencyDays,
      required this.recommendedSoilTypes,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scientific_name'] = Variable<String>(scientificName);
    map['popular_name'] = Variable<String>(popularName);
    if (!nullToAbsent || defaultIrrigationFrequencyDays != null) {
      map['default_irrigation_frequency_days'] =
          Variable<int>(defaultIrrigationFrequencyDays);
    }
    {
      map['recommended_soil_types'] = Variable<String>($SpeciesTableTable
          .$converterrecommendedSoilTypes
          .toSql(recommendedSoilTypes));
    }
    {
      map['sync_status'] = Variable<String>(
          $SpeciesTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SpeciesTableCompanion toCompanion(bool nullToAbsent) {
    return SpeciesTableCompanion(
      id: Value(id),
      scientificName: Value(scientificName),
      popularName: Value(popularName),
      defaultIrrigationFrequencyDays:
          defaultIrrigationFrequencyDays == null && nullToAbsent
              ? const Value.absent()
              : Value(defaultIrrigationFrequencyDays),
      recommendedSoilTypes: Value(recommendedSoilTypes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory SpeciesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesTableData(
      id: serializer.fromJson<String>(json['id']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      popularName: serializer.fromJson<String>(json['popularName']),
      defaultIrrigationFrequencyDays:
          serializer.fromJson<int?>(json['defaultIrrigationFrequencyDays']),
      recommendedSoilTypes:
          serializer.fromJson<List<String>>(json['recommendedSoilTypes']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scientificName': serializer.toJson<String>(scientificName),
      'popularName': serializer.toJson<String>(popularName),
      'defaultIrrigationFrequencyDays':
          serializer.toJson<int?>(defaultIrrigationFrequencyDays),
      'recommendedSoilTypes':
          serializer.toJson<List<String>>(recommendedSoilTypes),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SpeciesTableData copyWith(
          {String? id,
          String? scientificName,
          String? popularName,
          Value<int?> defaultIrrigationFrequencyDays = const Value.absent(),
          List<String>? recommendedSoilTypes,
          SyncStatus? syncStatus,
          DateTime? createdAt}) =>
      SpeciesTableData(
        id: id ?? this.id,
        scientificName: scientificName ?? this.scientificName,
        popularName: popularName ?? this.popularName,
        defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays.present
            ? defaultIrrigationFrequencyDays.value
            : this.defaultIrrigationFrequencyDays,
        recommendedSoilTypes: recommendedSoilTypes ?? this.recommendedSoilTypes,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  SpeciesTableData copyWithCompanion(SpeciesTableCompanion data) {
    return SpeciesTableData(
      id: data.id.present ? data.id.value : this.id,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      popularName:
          data.popularName.present ? data.popularName.value : this.popularName,
      defaultIrrigationFrequencyDays:
          data.defaultIrrigationFrequencyDays.present
              ? data.defaultIrrigationFrequencyDays.value
              : this.defaultIrrigationFrequencyDays,
      recommendedSoilTypes: data.recommendedSoilTypes.present
          ? data.recommendedSoilTypes.value
          : this.recommendedSoilTypes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesTableData(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('popularName: $popularName, ')
          ..write(
              'defaultIrrigationFrequencyDays: $defaultIrrigationFrequencyDays, ')
          ..write('recommendedSoilTypes: $recommendedSoilTypes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      scientificName,
      popularName,
      defaultIrrigationFrequencyDays,
      recommendedSoilTypes,
      syncStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesTableData &&
          other.id == this.id &&
          other.scientificName == this.scientificName &&
          other.popularName == this.popularName &&
          other.defaultIrrigationFrequencyDays ==
              this.defaultIrrigationFrequencyDays &&
          other.recommendedSoilTypes == this.recommendedSoilTypes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class SpeciesTableCompanion extends UpdateCompanion<SpeciesTableData> {
  final Value<String> id;
  final Value<String> scientificName;
  final Value<String> popularName;
  final Value<int?> defaultIrrigationFrequencyDays;
  final Value<List<String>> recommendedSoilTypes;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SpeciesTableCompanion({
    this.id = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.popularName = const Value.absent(),
    this.defaultIrrigationFrequencyDays = const Value.absent(),
    this.recommendedSoilTypes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeciesTableCompanion.insert({
    required String id,
    required String scientificName,
    required String popularName,
    this.defaultIrrigationFrequencyDays = const Value.absent(),
    required List<String> recommendedSoilTypes,
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        scientificName = Value(scientificName),
        popularName = Value(popularName),
        recommendedSoilTypes = Value(recommendedSoilTypes),
        createdAt = Value(createdAt);
  static Insertable<SpeciesTableData> custom({
    Expression<String>? id,
    Expression<String>? scientificName,
    Expression<String>? popularName,
    Expression<int>? defaultIrrigationFrequencyDays,
    Expression<String>? recommendedSoilTypes,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scientificName != null) 'scientific_name': scientificName,
      if (popularName != null) 'popular_name': popularName,
      if (defaultIrrigationFrequencyDays != null)
        'default_irrigation_frequency_days': defaultIrrigationFrequencyDays,
      if (recommendedSoilTypes != null)
        'recommended_soil_types': recommendedSoilTypes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeciesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? scientificName,
      Value<String>? popularName,
      Value<int?>? defaultIrrigationFrequencyDays,
      Value<List<String>>? recommendedSoilTypes,
      Value<SyncStatus>? syncStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SpeciesTableCompanion(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      popularName: popularName ?? this.popularName,
      defaultIrrigationFrequencyDays:
          defaultIrrigationFrequencyDays ?? this.defaultIrrigationFrequencyDays,
      recommendedSoilTypes: recommendedSoilTypes ?? this.recommendedSoilTypes,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (popularName.present) {
      map['popular_name'] = Variable<String>(popularName.value);
    }
    if (defaultIrrigationFrequencyDays.present) {
      map['default_irrigation_frequency_days'] =
          Variable<int>(defaultIrrigationFrequencyDays.value);
    }
    if (recommendedSoilTypes.present) {
      map['recommended_soil_types'] = Variable<String>($SpeciesTableTable
          .$converterrecommendedSoilTypes
          .toSql(recommendedSoilTypes.value));
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $SpeciesTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesTableCompanion(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('popularName: $popularName, ')
          ..write(
              'defaultIrrigationFrequencyDays: $defaultIrrigationFrequencyDays, ')
          ..write('recommendedSoilTypes: $recommendedSoilTypes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SoilsTableTable extends SoilsTable
    with TableInfo<$SoilsTableTable, SoilsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SoilsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _compositionMeta =
      const VerificationMeta('composition');
  @override
  late final GeneratedColumn<String> composition = GeneratedColumn<String>(
      'composition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<SyncStatus>($SoilsTableTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, composition, createdAt, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'soils';
  @override
  VerificationContext validateIntegrity(Insertable<SoilsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('composition')) {
      context.handle(
          _compositionMeta,
          composition.isAcceptableOrUnknown(
              data['composition']!, _compositionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SoilsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SoilsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      composition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}composition']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: $SoilsTableTable.$convertersyncStatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
    );
  }

  @override
  $SoilsTableTable createAlias(String alias) {
    return $SoilsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class SoilsTableData extends DataClass implements Insertable<SoilsTableData> {
  final String id;
  final String name;
  final String? composition;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  const SoilsTableData(
      {required this.id,
      required this.name,
      this.composition,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || composition != null) {
      map['composition'] = Variable<String>(composition);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['sync_status'] = Variable<String>(
          $SoilsTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    return map;
  }

  SoilsTableCompanion toCompanion(bool nullToAbsent) {
    return SoilsTableCompanion(
      id: Value(id),
      name: Value(name),
      composition: composition == null && nullToAbsent
          ? const Value.absent()
          : Value(composition),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory SoilsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SoilsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      composition: serializer.fromJson<String?>(json['composition']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'composition': serializer.toJson<String?>(composition),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  SoilsTableData copyWith(
          {String? id,
          String? name,
          Value<String?> composition = const Value.absent(),
          DateTime? createdAt,
          SyncStatus? syncStatus}) =>
      SoilsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        composition: composition.present ? composition.value : this.composition,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  SoilsTableData copyWithCompanion(SoilsTableCompanion data) {
    return SoilsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      composition:
          data.composition.present ? data.composition.value : this.composition,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SoilsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('composition: $composition, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, composition, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SoilsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.composition == this.composition &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class SoilsTableCompanion extends UpdateCompanion<SoilsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> composition;
  final Value<DateTime> createdAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const SoilsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.composition = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SoilsTableCompanion.insert({
    required String id,
    required String name,
    this.composition = const Value.absent(),
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<SoilsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? composition,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (composition != null) 'composition': composition,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SoilsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? composition,
      Value<DateTime>? createdAt,
      Value<SyncStatus>? syncStatus,
      Value<int>? rowid}) {
    return SoilsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      composition: composition ?? this.composition,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (composition.present) {
      map['composition'] = Variable<String>(composition.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $SoilsTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SoilsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('composition: $composition, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTableTable extends LocationsTable
    with TableInfo<$LocationsTableTable, LocationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<SyncStatus>($LocationsTableTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, latitude, longitude, createdAt, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(Insertable<LocationsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: $LocationsTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
    );
  }

  @override
  $LocationsTableTable createAlias(String alias) {
    return $LocationsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class LocationsTableData extends DataClass
    implements Insertable<LocationsTableData> {
  final String id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  const LocationsTableData(
      {required this.id,
      required this.name,
      this.description,
      this.latitude,
      this.longitude,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['sync_status'] = Variable<String>(
          $LocationsTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    return map;
  }

  LocationsTableCompanion toCompanion(bool nullToAbsent) {
    return LocationsTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocationsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  LocationsTableData copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          DateTime? createdAt,
          SyncStatus? syncStatus}) =>
      LocationsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  LocationsTableData copyWithCompanion(LocationsTableCompanion data) {
    return LocationsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, description, latitude, longitude, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class LocationsTableCompanion extends UpdateCompanion<LocationsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> createdAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const LocationsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<LocationsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<DateTime>? createdAt,
      Value<SyncStatus>? syncStatus,
      Value<int>? rowid}) {
    return LocationsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $LocationsTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlantsTableTable extends PlantsTable
    with TableInfo<$PlantsTableTable, PlantsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesIdMeta =
      const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
      'species_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES species (id) ON DELETE RESTRICT'));
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _soilTypeMeta =
      const VerificationMeta('soilType');
  @override
  late final GeneratedColumn<String> soilType = GeneratedColumn<String>(
      'soil_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES soils (id)'));
  static const VerificationMeta _irrigationFrequencyDaysMeta =
      const VerificationMeta('irrigationFrequencyDays');
  @override
  late final GeneratedColumn<int> irrigationFrequencyDays =
      GeneratedColumn<int>('irrigation_frequency_days', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _acquisitionDateMeta =
      const VerificationMeta('acquisitionDate');
  @override
  late final GeneratedColumn<DateTime> acquisitionDate =
      GeneratedColumn<DateTime>('acquisition_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES locations (id) ON DELETE SET NULL'));
  static const VerificationMeta _lastIrrigatedAtMeta =
      const VerificationMeta('lastIrrigatedAt');
  @override
  late final GeneratedColumn<DateTime> lastIrrigatedAt =
      GeneratedColumn<DateTime>('last_irrigated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<SyncStatus>($PlantsTableTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        speciesId,
        nickname,
        soilType,
        irrigationFrequencyDays,
        acquisitionDate,
        location,
        locationId,
        lastIrrigatedAt,
        createdAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plants';
  @override
  VerificationContext validateIntegrity(Insertable<PlantsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(_speciesIdMeta,
          speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta));
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('soil_type')) {
      context.handle(_soilTypeMeta,
          soilType.isAcceptableOrUnknown(data['soil_type']!, _soilTypeMeta));
    } else if (isInserting) {
      context.missing(_soilTypeMeta);
    }
    if (data.containsKey('irrigation_frequency_days')) {
      context.handle(
          _irrigationFrequencyDaysMeta,
          irrigationFrequencyDays.isAcceptableOrUnknown(
              data['irrigation_frequency_days']!,
              _irrigationFrequencyDaysMeta));
    }
    if (data.containsKey('acquisition_date')) {
      context.handle(
          _acquisitionDateMeta,
          acquisitionDate.isAcceptableOrUnknown(
              data['acquisition_date']!, _acquisitionDateMeta));
    } else if (isInserting) {
      context.missing(_acquisitionDateMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('last_irrigated_at')) {
      context.handle(
          _lastIrrigatedAtMeta,
          lastIrrigatedAt.isAcceptableOrUnknown(
              data['last_irrigated_at']!, _lastIrrigatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      speciesId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species_id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      soilType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}soil_type'])!,
      irrigationFrequencyDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}irrigation_frequency_days']),
      acquisitionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}acquisition_date'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      lastIrrigatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_irrigated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: $PlantsTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
    );
  }

  @override
  $PlantsTableTable createAlias(String alias) {
    return $PlantsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class PlantsTableData extends DataClass implements Insertable<PlantsTableData> {
  final String id;
  final String speciesId;
  final String nickname;
  final String soilType;

  /// Null means: inherit from species.defaultIrrigationFrequencyDays
  final int? irrigationFrequencyDays;
  final DateTime acquisitionDate;
  final String? location;
  final String? locationId;
  final DateTime? lastIrrigatedAt;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  const PlantsTableData(
      {required this.id,
      required this.speciesId,
      required this.nickname,
      required this.soilType,
      this.irrigationFrequencyDays,
      required this.acquisitionDate,
      this.location,
      this.locationId,
      this.lastIrrigatedAt,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['species_id'] = Variable<String>(speciesId);
    map['nickname'] = Variable<String>(nickname);
    map['soil_type'] = Variable<String>(soilType);
    if (!nullToAbsent || irrigationFrequencyDays != null) {
      map['irrigation_frequency_days'] = Variable<int>(irrigationFrequencyDays);
    }
    map['acquisition_date'] = Variable<DateTime>(acquisitionDate);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || lastIrrigatedAt != null) {
      map['last_irrigated_at'] = Variable<DateTime>(lastIrrigatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['sync_status'] = Variable<String>(
          $PlantsTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    return map;
  }

  PlantsTableCompanion toCompanion(bool nullToAbsent) {
    return PlantsTableCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      nickname: Value(nickname),
      soilType: Value(soilType),
      irrigationFrequencyDays: irrigationFrequencyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(irrigationFrequencyDays),
      acquisitionDate: Value(acquisitionDate),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      lastIrrigatedAt: lastIrrigatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastIrrigatedAt),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory PlantsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantsTableData(
      id: serializer.fromJson<String>(json['id']),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      nickname: serializer.fromJson<String>(json['nickname']),
      soilType: serializer.fromJson<String>(json['soilType']),
      irrigationFrequencyDays:
          serializer.fromJson<int?>(json['irrigationFrequencyDays']),
      acquisitionDate: serializer.fromJson<DateTime>(json['acquisitionDate']),
      location: serializer.fromJson<String?>(json['location']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      lastIrrigatedAt: serializer.fromJson<DateTime?>(json['lastIrrigatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'speciesId': serializer.toJson<String>(speciesId),
      'nickname': serializer.toJson<String>(nickname),
      'soilType': serializer.toJson<String>(soilType),
      'irrigationFrequencyDays':
          serializer.toJson<int?>(irrigationFrequencyDays),
      'acquisitionDate': serializer.toJson<DateTime>(acquisitionDate),
      'location': serializer.toJson<String?>(location),
      'locationId': serializer.toJson<String?>(locationId),
      'lastIrrigatedAt': serializer.toJson<DateTime?>(lastIrrigatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  PlantsTableData copyWith(
          {String? id,
          String? speciesId,
          String? nickname,
          String? soilType,
          Value<int?> irrigationFrequencyDays = const Value.absent(),
          DateTime? acquisitionDate,
          Value<String?> location = const Value.absent(),
          Value<String?> locationId = const Value.absent(),
          Value<DateTime?> lastIrrigatedAt = const Value.absent(),
          DateTime? createdAt,
          SyncStatus? syncStatus}) =>
      PlantsTableData(
        id: id ?? this.id,
        speciesId: speciesId ?? this.speciesId,
        nickname: nickname ?? this.nickname,
        soilType: soilType ?? this.soilType,
        irrigationFrequencyDays: irrigationFrequencyDays.present
            ? irrigationFrequencyDays.value
            : this.irrigationFrequencyDays,
        acquisitionDate: acquisitionDate ?? this.acquisitionDate,
        location: location.present ? location.value : this.location,
        locationId: locationId.present ? locationId.value : this.locationId,
        lastIrrigatedAt: lastIrrigatedAt.present
            ? lastIrrigatedAt.value
            : this.lastIrrigatedAt,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  PlantsTableData copyWithCompanion(PlantsTableCompanion data) {
    return PlantsTableData(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      soilType: data.soilType.present ? data.soilType.value : this.soilType,
      irrigationFrequencyDays: data.irrigationFrequencyDays.present
          ? data.irrigationFrequencyDays.value
          : this.irrigationFrequencyDays,
      acquisitionDate: data.acquisitionDate.present
          ? data.acquisitionDate.value
          : this.acquisitionDate,
      location: data.location.present ? data.location.value : this.location,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      lastIrrigatedAt: data.lastIrrigatedAt.present
          ? data.lastIrrigatedAt.value
          : this.lastIrrigatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantsTableData(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('nickname: $nickname, ')
          ..write('soilType: $soilType, ')
          ..write('irrigationFrequencyDays: $irrigationFrequencyDays, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('location: $location, ')
          ..write('locationId: $locationId, ')
          ..write('lastIrrigatedAt: $lastIrrigatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      speciesId,
      nickname,
      soilType,
      irrigationFrequencyDays,
      acquisitionDate,
      location,
      locationId,
      lastIrrigatedAt,
      createdAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantsTableData &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.nickname == this.nickname &&
          other.soilType == this.soilType &&
          other.irrigationFrequencyDays == this.irrigationFrequencyDays &&
          other.acquisitionDate == this.acquisitionDate &&
          other.location == this.location &&
          other.locationId == this.locationId &&
          other.lastIrrigatedAt == this.lastIrrigatedAt &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class PlantsTableCompanion extends UpdateCompanion<PlantsTableData> {
  final Value<String> id;
  final Value<String> speciesId;
  final Value<String> nickname;
  final Value<String> soilType;
  final Value<int?> irrigationFrequencyDays;
  final Value<DateTime> acquisitionDate;
  final Value<String?> location;
  final Value<String?> locationId;
  final Value<DateTime?> lastIrrigatedAt;
  final Value<DateTime> createdAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const PlantsTableCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.soilType = const Value.absent(),
    this.irrigationFrequencyDays = const Value.absent(),
    this.acquisitionDate = const Value.absent(),
    this.location = const Value.absent(),
    this.locationId = const Value.absent(),
    this.lastIrrigatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantsTableCompanion.insert({
    required String id,
    required String speciesId,
    required String nickname,
    required String soilType,
    this.irrigationFrequencyDays = const Value.absent(),
    required DateTime acquisitionDate,
    this.location = const Value.absent(),
    this.locationId = const Value.absent(),
    this.lastIrrigatedAt = const Value.absent(),
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        speciesId = Value(speciesId),
        nickname = Value(nickname),
        soilType = Value(soilType),
        acquisitionDate = Value(acquisitionDate),
        createdAt = Value(createdAt);
  static Insertable<PlantsTableData> custom({
    Expression<String>? id,
    Expression<String>? speciesId,
    Expression<String>? nickname,
    Expression<String>? soilType,
    Expression<int>? irrigationFrequencyDays,
    Expression<DateTime>? acquisitionDate,
    Expression<String>? location,
    Expression<String>? locationId,
    Expression<DateTime>? lastIrrigatedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (nickname != null) 'nickname': nickname,
      if (soilType != null) 'soil_type': soilType,
      if (irrigationFrequencyDays != null)
        'irrigation_frequency_days': irrigationFrequencyDays,
      if (acquisitionDate != null) 'acquisition_date': acquisitionDate,
      if (location != null) 'location': location,
      if (locationId != null) 'location_id': locationId,
      if (lastIrrigatedAt != null) 'last_irrigated_at': lastIrrigatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? speciesId,
      Value<String>? nickname,
      Value<String>? soilType,
      Value<int?>? irrigationFrequencyDays,
      Value<DateTime>? acquisitionDate,
      Value<String?>? location,
      Value<String?>? locationId,
      Value<DateTime?>? lastIrrigatedAt,
      Value<DateTime>? createdAt,
      Value<SyncStatus>? syncStatus,
      Value<int>? rowid}) {
    return PlantsTableCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      nickname: nickname ?? this.nickname,
      soilType: soilType ?? this.soilType,
      irrigationFrequencyDays:
          irrigationFrequencyDays ?? this.irrigationFrequencyDays,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      location: location ?? this.location,
      locationId: locationId ?? this.locationId,
      lastIrrigatedAt: lastIrrigatedAt ?? this.lastIrrigatedAt,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (soilType.present) {
      map['soil_type'] = Variable<String>(soilType.value);
    }
    if (irrigationFrequencyDays.present) {
      map['irrigation_frequency_days'] =
          Variable<int>(irrigationFrequencyDays.value);
    }
    if (acquisitionDate.present) {
      map['acquisition_date'] = Variable<DateTime>(acquisitionDate.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (lastIrrigatedAt.present) {
      map['last_irrigated_at'] = Variable<DateTime>(lastIrrigatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $PlantsTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantsTableCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('nickname: $nickname, ')
          ..write('soilType: $soilType, ')
          ..write('irrigationFrequencyDays: $irrigationFrequencyDays, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('location: $location, ')
          ..write('locationId: $locationId, ')
          ..write('lastIrrigatedAt: $lastIrrigatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTableTable extends EntriesTable
    with TableInfo<$EntriesTableTable, EntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plantIdMeta =
      const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
      'plant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES plants (id) ON DELETE CASCADE'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<EntryType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<EntryType>($EntriesTableTable.$convertertype);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<SyncStatus>($EntriesTableTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns =>
      [id, plantId, date, photoPath, note, type, createdAt, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<EntriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta,
          plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntriesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      plantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plant_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      type: $EntriesTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: $EntriesTableTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
    );
  }

  @override
  $EntriesTableTable createAlias(String alias) {
    return $EntriesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<EntryType, String> $convertertype =
      const EntryTypeConverter();
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class EntriesTableData extends DataClass
    implements Insertable<EntriesTableData> {
  final String id;
  final String plantId;
  final DateTime date;
  final String? photoPath;
  final String? note;
  final EntryType type;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  const EntriesTableData(
      {required this.id,
      required this.plantId,
      required this.date,
      this.photoPath,
      this.note,
      required this.type,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['type'] =
          Variable<String>($EntriesTableTable.$convertertype.toSql(type));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['sync_status'] = Variable<String>(
          $EntriesTableTable.$convertersyncStatus.toSql(syncStatus));
    }
    return map;
  }

  EntriesTableCompanion toCompanion(bool nullToAbsent) {
    return EntriesTableCompanion(
      id: Value(id),
      plantId: Value(plantId),
      date: Value(date),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      type: Value(type),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory EntriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plantId']),
      date: serializer.fromJson<DateTime>(json['date']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      note: serializer.fromJson<String?>(json['note']),
      type: serializer.fromJson<EntryType>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plantId': serializer.toJson<String>(plantId),
      'date': serializer.toJson<DateTime>(date),
      'photoPath': serializer.toJson<String?>(photoPath),
      'note': serializer.toJson<String?>(note),
      'type': serializer.toJson<EntryType>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  EntriesTableData copyWith(
          {String? id,
          String? plantId,
          DateTime? date,
          Value<String?> photoPath = const Value.absent(),
          Value<String?> note = const Value.absent(),
          EntryType? type,
          DateTime? createdAt,
          SyncStatus? syncStatus}) =>
      EntriesTableData(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        date: date ?? this.date,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        note: note.present ? note.value : this.note,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  EntriesTableData copyWithCompanion(EntriesTableCompanion data) {
    return EntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      date: data.date.present ? data.date.value : this.date,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      note: data.note.present ? data.note.value : this.note,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntriesTableData(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('date: $date, ')
          ..write('photoPath: $photoPath, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, plantId, date, photoPath, note, type, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntriesTableData &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.date == this.date &&
          other.photoPath == this.photoPath &&
          other.note == this.note &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class EntriesTableCompanion extends UpdateCompanion<EntriesTableData> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<DateTime> date;
  final Value<String?> photoPath;
  final Value<String?> note;
  final Value<EntryType> type;
  final Value<DateTime> createdAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const EntriesTableCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.date = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.note = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesTableCompanion.insert({
    required String id,
    required String plantId,
    required DateTime date,
    this.photoPath = const Value.absent(),
    this.note = const Value.absent(),
    required EntryType type,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        plantId = Value(plantId),
        date = Value(date),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<EntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<DateTime>? date,
    Expression<String>? photoPath,
    Expression<String>? note,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (date != null) 'date': date,
      if (photoPath != null) 'photo_path': photoPath,
      if (note != null) 'note': note,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? plantId,
      Value<DateTime>? date,
      Value<String?>? photoPath,
      Value<String?>? note,
      Value<EntryType>? type,
      Value<DateTime>? createdAt,
      Value<SyncStatus>? syncStatus,
      Value<int>? rowid}) {
    return EntriesTableCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      date: date ?? this.date,
      photoPath: photoPath ?? this.photoPath,
      note: note ?? this.note,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($EntriesTableTable.$convertertype.toSql(type.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $EntriesTableTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('date: $date, ')
          ..write('photoPath: $photoPath, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _processedMeta =
      const VerificationMeta('processed');
  @override
  late final GeneratedColumn<bool> processed = GeneratedColumn<bool>(
      'processed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("processed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, operation, payload, processed, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('processed')) {
      context.handle(_processedMeta,
          processed.isAcceptableOrUnknown(data['processed']!, _processedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      processed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}processed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  final int id;

  /// 'species' | 'plant' | 'entry'
  final String entityType;
  final String entityId;

  /// 'create' | 'update' | 'delete'
  final String operation;

  /// JSON-encoded snapshot of the entity at the time of the write
  final String payload;
  final bool processed;
  final DateTime createdAt;
  const SyncQueueTableData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.payload,
      required this.processed,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['processed'] = Variable<bool>(processed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      processed: Value(processed),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      processed: serializer.fromJson<bool>(json['processed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'processed': serializer.toJson<bool>(processed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueTableData copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? operation,
          String? payload,
          bool? processed,
          DateTime? createdAt}) =>
      SyncQueueTableData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        processed: processed ?? this.processed,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      processed: data.processed.present ? data.processed.value : this.processed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('processed: $processed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, operation, payload, processed, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.processed == this.processed &&
          other.createdAt == this.createdAt);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<bool> processed;
  final Value<DateTime> createdAt;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.processed = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    this.processed = const Value.absent(),
    required DateTime createdAt,
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueTableData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<bool>? processed,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (processed != null) 'processed': processed,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? payload,
      Value<bool>? processed,
      Value<DateTime>? createdAt}) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      processed: processed ?? this.processed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (processed.present) {
      map['processed'] = Variable<bool>(processed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('processed: $processed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SpeciesTableTable speciesTable = $SpeciesTableTable(this);
  late final $SoilsTableTable soilsTable = $SoilsTableTable(this);
  late final $LocationsTableTable locationsTable = $LocationsTableTable(this);
  late final $PlantsTableTable plantsTable = $PlantsTableTable(this);
  late final $EntriesTableTable entriesTable = $EntriesTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        speciesTable,
        soilsTable,
        locationsTable,
        plantsTable,
        entriesTable,
        syncQueueTable
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('locations',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('plants', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('plants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('entries', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SpeciesTableTableCreateCompanionBuilder = SpeciesTableCompanion
    Function({
  required String id,
  required String scientificName,
  required String popularName,
  Value<int?> defaultIrrigationFrequencyDays,
  required List<String> recommendedSoilTypes,
  Value<SyncStatus> syncStatus,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SpeciesTableTableUpdateCompanionBuilder = SpeciesTableCompanion
    Function({
  Value<String> id,
  Value<String> scientificName,
  Value<String> popularName,
  Value<int?> defaultIrrigationFrequencyDays,
  Value<List<String>> recommendedSoilTypes,
  Value<SyncStatus> syncStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SpeciesTableTableReferences extends BaseReferences<_$AppDatabase,
    $SpeciesTableTable, SpeciesTableData> {
  $$SpeciesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTableTable, List<PlantsTableData>>
      _plantsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plantsTable,
              aliasName: $_aliasNameGenerator(
                  db.speciesTable.id, db.plantsTable.speciesId));

  $$PlantsTableTableProcessedTableManager get plantsTableRefs {
    final manager = $$PlantsTableTableTableManager($_db, $_db.plantsTable)
        .filter((f) => f.speciesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_plantsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SpeciesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scientificName => $composableBuilder(
      column: $table.scientificName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get popularName => $composableBuilder(
      column: $table.popularName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultIrrigationFrequencyDays => $composableBuilder(
      column: $table.defaultIrrigationFrequencyDays,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get recommendedSoilTypes => $composableBuilder(
          column: $table.recommendedSoilTypes,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> plantsTableRefs(
      Expression<bool> Function($$PlantsTableTableFilterComposer f) f) {
    final $$PlantsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.speciesId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableFilterComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SpeciesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scientificName => $composableBuilder(
      column: $table.scientificName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get popularName => $composableBuilder(
      column: $table.popularName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultIrrigationFrequencyDays => $composableBuilder(
      column: $table.defaultIrrigationFrequencyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recommendedSoilTypes => $composableBuilder(
      column: $table.recommendedSoilTypes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SpeciesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scientificName => $composableBuilder(
      column: $table.scientificName, builder: (column) => column);

  GeneratedColumn<String> get popularName => $composableBuilder(
      column: $table.popularName, builder: (column) => column);

  GeneratedColumn<int> get defaultIrrigationFrequencyDays => $composableBuilder(
      column: $table.defaultIrrigationFrequencyDays,
      builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String>
      get recommendedSoilTypes => $composableBuilder(
          column: $table.recommendedSoilTypes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> plantsTableRefs<T extends Object>(
      Expression<T> Function($$PlantsTableTableAnnotationComposer a) f) {
    final $$PlantsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.speciesId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SpeciesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SpeciesTableTable,
    SpeciesTableData,
    $$SpeciesTableTableFilterComposer,
    $$SpeciesTableTableOrderingComposer,
    $$SpeciesTableTableAnnotationComposer,
    $$SpeciesTableTableCreateCompanionBuilder,
    $$SpeciesTableTableUpdateCompanionBuilder,
    (SpeciesTableData, $$SpeciesTableTableReferences),
    SpeciesTableData,
    PrefetchHooks Function({bool plantsTableRefs})> {
  $$SpeciesTableTableTableManager(_$AppDatabase db, $SpeciesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> scientificName = const Value.absent(),
            Value<String> popularName = const Value.absent(),
            Value<int?> defaultIrrigationFrequencyDays = const Value.absent(),
            Value<List<String>> recommendedSoilTypes = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpeciesTableCompanion(
            id: id,
            scientificName: scientificName,
            popularName: popularName,
            defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays,
            recommendedSoilTypes: recommendedSoilTypes,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String scientificName,
            required String popularName,
            Value<int?> defaultIrrigationFrequencyDays = const Value.absent(),
            required List<String> recommendedSoilTypes,
            Value<SyncStatus> syncStatus = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SpeciesTableCompanion.insert(
            id: id,
            scientificName: scientificName,
            popularName: popularName,
            defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays,
            recommendedSoilTypes: recommendedSoilTypes,
            syncStatus: syncStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SpeciesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({plantsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plantsTableRefs) db.plantsTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plantsTableRefs)
                    await $_getPrefetchedData<SpeciesTableData,
                            $SpeciesTableTable, PlantsTableData>(
                        currentTable: table,
                        referencedTable: $$SpeciesTableTableReferences
                            ._plantsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SpeciesTableTableReferences(db, table, p0)
                                .plantsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.speciesId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SpeciesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SpeciesTableTable,
    SpeciesTableData,
    $$SpeciesTableTableFilterComposer,
    $$SpeciesTableTableOrderingComposer,
    $$SpeciesTableTableAnnotationComposer,
    $$SpeciesTableTableCreateCompanionBuilder,
    $$SpeciesTableTableUpdateCompanionBuilder,
    (SpeciesTableData, $$SpeciesTableTableReferences),
    SpeciesTableData,
    PrefetchHooks Function({bool plantsTableRefs})>;
typedef $$SoilsTableTableCreateCompanionBuilder = SoilsTableCompanion Function({
  required String id,
  required String name,
  Value<String?> composition,
  required DateTime createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});
typedef $$SoilsTableTableUpdateCompanionBuilder = SoilsTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> composition,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$SoilsTableTableReferences
    extends BaseReferences<_$AppDatabase, $SoilsTableTable, SoilsTableData> {
  $$SoilsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTableTable, List<PlantsTableData>>
      _plantsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.plantsTable,
          aliasName:
              $_aliasNameGenerator(db.soilsTable.id, db.plantsTable.soilType));

  $$PlantsTableTableProcessedTableManager get plantsTableRefs {
    final manager = $$PlantsTableTableTableManager($_db, $_db.plantsTable)
        .filter((f) => f.soilType.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_plantsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SoilsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SoilsTableTable> {
  $$SoilsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> plantsTableRefs(
      Expression<bool> Function($$PlantsTableTableFilterComposer f) f) {
    final $$PlantsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.soilType,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableFilterComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SoilsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SoilsTableTable> {
  $$SoilsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$SoilsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SoilsTableTable> {
  $$SoilsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  Expression<T> plantsTableRefs<T extends Object>(
      Expression<T> Function($$PlantsTableTableAnnotationComposer a) f) {
    final $$PlantsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.soilType,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SoilsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SoilsTableTable,
    SoilsTableData,
    $$SoilsTableTableFilterComposer,
    $$SoilsTableTableOrderingComposer,
    $$SoilsTableTableAnnotationComposer,
    $$SoilsTableTableCreateCompanionBuilder,
    $$SoilsTableTableUpdateCompanionBuilder,
    (SoilsTableData, $$SoilsTableTableReferences),
    SoilsTableData,
    PrefetchHooks Function({bool plantsTableRefs})> {
  $$SoilsTableTableTableManager(_$AppDatabase db, $SoilsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SoilsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SoilsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SoilsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> composition = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SoilsTableCompanion(
            id: id,
            name: name,
            composition: composition,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> composition = const Value.absent(),
            required DateTime createdAt,
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SoilsTableCompanion.insert(
            id: id,
            name: name,
            composition: composition,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SoilsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({plantsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plantsTableRefs) db.plantsTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plantsTableRefs)
                    await $_getPrefetchedData<SoilsTableData, $SoilsTableTable,
                            PlantsTableData>(
                        currentTable: table,
                        referencedTable: $$SoilsTableTableReferences
                            ._plantsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SoilsTableTableReferences(db, table, p0)
                                .plantsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.soilType == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SoilsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SoilsTableTable,
    SoilsTableData,
    $$SoilsTableTableFilterComposer,
    $$SoilsTableTableOrderingComposer,
    $$SoilsTableTableAnnotationComposer,
    $$SoilsTableTableCreateCompanionBuilder,
    $$SoilsTableTableUpdateCompanionBuilder,
    (SoilsTableData, $$SoilsTableTableReferences),
    SoilsTableData,
    PrefetchHooks Function({bool plantsTableRefs})>;
typedef $$LocationsTableTableCreateCompanionBuilder = LocationsTableCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<double?> latitude,
  Value<double?> longitude,
  required DateTime createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});
typedef $$LocationsTableTableUpdateCompanionBuilder = LocationsTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$LocationsTableTableReferences extends BaseReferences<
    _$AppDatabase, $LocationsTableTable, LocationsTableData> {
  $$LocationsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTableTable, List<PlantsTableData>>
      _plantsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plantsTable,
              aliasName: $_aliasNameGenerator(
                  db.locationsTable.id, db.plantsTable.locationId));

  $$PlantsTableTableProcessedTableManager get plantsTableRefs {
    final manager = $$PlantsTableTableTableManager($_db, $_db.plantsTable)
        .filter((f) => f.locationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_plantsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTableTable> {
  $$LocationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> plantsTableRefs(
      Expression<bool> Function($$PlantsTableTableFilterComposer f) f) {
    final $$PlantsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableFilterComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTableTable> {
  $$LocationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$LocationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTableTable> {
  $$LocationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  Expression<T> plantsTableRefs<T extends Object>(
      Expression<T> Function($$PlantsTableTableAnnotationComposer a) f) {
    final $$PlantsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocationsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocationsTableTable,
    LocationsTableData,
    $$LocationsTableTableFilterComposer,
    $$LocationsTableTableOrderingComposer,
    $$LocationsTableTableAnnotationComposer,
    $$LocationsTableTableCreateCompanionBuilder,
    $$LocationsTableTableUpdateCompanionBuilder,
    (LocationsTableData, $$LocationsTableTableReferences),
    LocationsTableData,
    PrefetchHooks Function({bool plantsTableRefs})> {
  $$LocationsTableTableTableManager(
      _$AppDatabase db, $LocationsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsTableCompanion(
            id: id,
            name: name,
            description: description,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            required DateTime createdAt,
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsTableCompanion.insert(
            id: id,
            name: name,
            description: description,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocationsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({plantsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plantsTableRefs) db.plantsTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plantsTableRefs)
                    await $_getPrefetchedData<LocationsTableData,
                            $LocationsTableTable, PlantsTableData>(
                        currentTable: table,
                        referencedTable: $$LocationsTableTableReferences
                            ._plantsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocationsTableTableReferences(db, table, p0)
                                .plantsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.locationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocationsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocationsTableTable,
    LocationsTableData,
    $$LocationsTableTableFilterComposer,
    $$LocationsTableTableOrderingComposer,
    $$LocationsTableTableAnnotationComposer,
    $$LocationsTableTableCreateCompanionBuilder,
    $$LocationsTableTableUpdateCompanionBuilder,
    (LocationsTableData, $$LocationsTableTableReferences),
    LocationsTableData,
    PrefetchHooks Function({bool plantsTableRefs})>;
typedef $$PlantsTableTableCreateCompanionBuilder = PlantsTableCompanion
    Function({
  required String id,
  required String speciesId,
  required String nickname,
  required String soilType,
  Value<int?> irrigationFrequencyDays,
  required DateTime acquisitionDate,
  Value<String?> location,
  Value<String?> locationId,
  Value<DateTime?> lastIrrigatedAt,
  required DateTime createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});
typedef $$PlantsTableTableUpdateCompanionBuilder = PlantsTableCompanion
    Function({
  Value<String> id,
  Value<String> speciesId,
  Value<String> nickname,
  Value<String> soilType,
  Value<int?> irrigationFrequencyDays,
  Value<DateTime> acquisitionDate,
  Value<String?> location,
  Value<String?> locationId,
  Value<DateTime?> lastIrrigatedAt,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$PlantsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PlantsTableTable, PlantsTableData> {
  $$PlantsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpeciesTableTable _speciesIdTable(_$AppDatabase db) =>
      db.speciesTable.createAlias(
          $_aliasNameGenerator(db.plantsTable.speciesId, db.speciesTable.id));

  $$SpeciesTableTableProcessedTableManager get speciesId {
    final $_column = $_itemColumn<String>('species_id')!;

    final manager = $$SpeciesTableTableTableManager($_db, $_db.speciesTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speciesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SoilsTableTable _soilTypeTable(_$AppDatabase db) =>
      db.soilsTable.createAlias(
          $_aliasNameGenerator(db.plantsTable.soilType, db.soilsTable.id));

  $$SoilsTableTableProcessedTableManager get soilType {
    final $_column = $_itemColumn<String>('soil_type')!;

    final manager = $$SoilsTableTableTableManager($_db, $_db.soilsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_soilTypeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocationsTableTable _locationIdTable(_$AppDatabase db) =>
      db.locationsTable.createAlias($_aliasNameGenerator(
          db.plantsTable.locationId, db.locationsTable.id));

  $$LocationsTableTableProcessedTableManager? get locationId {
    final $_column = $_itemColumn<String>('location_id');
    if ($_column == null) return null;
    final manager = $$LocationsTableTableTableManager($_db, $_db.locationsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_locationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EntriesTableTable, List<EntriesTableData>>
      _entriesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.entriesTable,
          aliasName:
              $_aliasNameGenerator(db.plantsTable.id, db.entriesTable.plantId));

  $$EntriesTableTableProcessedTableManager get entriesTableRefs {
    final manager = $$EntriesTableTableTableManager($_db, $_db.entriesTable)
        .filter((f) => f.plantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlantsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlantsTableTable> {
  $$PlantsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get irrigationFrequencyDays => $composableBuilder(
      column: $table.irrigationFrequencyDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get acquisitionDate => $composableBuilder(
      column: $table.acquisitionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastIrrigatedAt => $composableBuilder(
      column: $table.lastIrrigatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$SpeciesTableTableFilterComposer get speciesId {
    final $$SpeciesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.speciesId,
        referencedTable: $db.speciesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpeciesTableTableFilterComposer(
              $db: $db,
              $table: $db.speciesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SoilsTableTableFilterComposer get soilType {
    final $$SoilsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.soilType,
        referencedTable: $db.soilsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SoilsTableTableFilterComposer(
              $db: $db,
              $table: $db.soilsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocationsTableTableFilterComposer get locationId {
    final $$LocationsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $db.locationsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableTableFilterComposer(
              $db: $db,
              $table: $db.locationsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> entriesTableRefs(
      Expression<bool> Function($$EntriesTableTableFilterComposer f) f) {
    final $$EntriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entriesTable,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableTableFilterComposer(
              $db: $db,
              $table: $db.entriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlantsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantsTableTable> {
  $$PlantsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get irrigationFrequencyDays => $composableBuilder(
      column: $table.irrigationFrequencyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get acquisitionDate => $composableBuilder(
      column: $table.acquisitionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastIrrigatedAt => $composableBuilder(
      column: $table.lastIrrigatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$SpeciesTableTableOrderingComposer get speciesId {
    final $$SpeciesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.speciesId,
        referencedTable: $db.speciesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpeciesTableTableOrderingComposer(
              $db: $db,
              $table: $db.speciesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SoilsTableTableOrderingComposer get soilType {
    final $$SoilsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.soilType,
        referencedTable: $db.soilsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SoilsTableTableOrderingComposer(
              $db: $db,
              $table: $db.soilsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocationsTableTableOrderingComposer get locationId {
    final $$LocationsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $db.locationsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableTableOrderingComposer(
              $db: $db,
              $table: $db.locationsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlantsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantsTableTable> {
  $$PlantsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<int> get irrigationFrequencyDays => $composableBuilder(
      column: $table.irrigationFrequencyDays, builder: (column) => column);

  GeneratedColumn<DateTime> get acquisitionDate => $composableBuilder(
      column: $table.acquisitionDate, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get lastIrrigatedAt => $composableBuilder(
      column: $table.lastIrrigatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  $$SpeciesTableTableAnnotationComposer get speciesId {
    final $$SpeciesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.speciesId,
        referencedTable: $db.speciesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpeciesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.speciesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SoilsTableTableAnnotationComposer get soilType {
    final $$SoilsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.soilType,
        referencedTable: $db.soilsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SoilsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.soilsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocationsTableTableAnnotationComposer get locationId {
    final $$LocationsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $db.locationsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocationsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.locationsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> entriesTableRefs<T extends Object>(
      Expression<T> Function($$EntriesTableTableAnnotationComposer a) f) {
    final $$EntriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entriesTable,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.entriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlantsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlantsTableTable,
    PlantsTableData,
    $$PlantsTableTableFilterComposer,
    $$PlantsTableTableOrderingComposer,
    $$PlantsTableTableAnnotationComposer,
    $$PlantsTableTableCreateCompanionBuilder,
    $$PlantsTableTableUpdateCompanionBuilder,
    (PlantsTableData, $$PlantsTableTableReferences),
    PlantsTableData,
    PrefetchHooks Function(
        {bool speciesId,
        bool soilType,
        bool locationId,
        bool entriesTableRefs})> {
  $$PlantsTableTableTableManager(_$AppDatabase db, $PlantsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> speciesId = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String> soilType = const Value.absent(),
            Value<int?> irrigationFrequencyDays = const Value.absent(),
            Value<DateTime> acquisitionDate = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<DateTime?> lastIrrigatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlantsTableCompanion(
            id: id,
            speciesId: speciesId,
            nickname: nickname,
            soilType: soilType,
            irrigationFrequencyDays: irrigationFrequencyDays,
            acquisitionDate: acquisitionDate,
            location: location,
            locationId: locationId,
            lastIrrigatedAt: lastIrrigatedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String speciesId,
            required String nickname,
            required String soilType,
            Value<int?> irrigationFrequencyDays = const Value.absent(),
            required DateTime acquisitionDate,
            Value<String?> location = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<DateTime?> lastIrrigatedAt = const Value.absent(),
            required DateTime createdAt,
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlantsTableCompanion.insert(
            id: id,
            speciesId: speciesId,
            nickname: nickname,
            soilType: soilType,
            irrigationFrequencyDays: irrigationFrequencyDays,
            acquisitionDate: acquisitionDate,
            location: location,
            locationId: locationId,
            lastIrrigatedAt: lastIrrigatedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlantsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {speciesId = false,
              soilType = false,
              locationId = false,
              entriesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entriesTableRefs) db.entriesTable],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (speciesId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.speciesId,
                    referencedTable:
                        $$PlantsTableTableReferences._speciesIdTable(db),
                    referencedColumn:
                        $$PlantsTableTableReferences._speciesIdTable(db).id,
                  ) as T;
                }
                if (soilType) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.soilType,
                    referencedTable:
                        $$PlantsTableTableReferences._soilTypeTable(db),
                    referencedColumn:
                        $$PlantsTableTableReferences._soilTypeTable(db).id,
                  ) as T;
                }
                if (locationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.locationId,
                    referencedTable:
                        $$PlantsTableTableReferences._locationIdTable(db),
                    referencedColumn:
                        $$PlantsTableTableReferences._locationIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesTableRefs)
                    await $_getPrefetchedData<PlantsTableData,
                            $PlantsTableTable, EntriesTableData>(
                        currentTable: table,
                        referencedTable: $$PlantsTableTableReferences
                            ._entriesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlantsTableTableReferences(db, table, p0)
                                .entriesTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.plantId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlantsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlantsTableTable,
    PlantsTableData,
    $$PlantsTableTableFilterComposer,
    $$PlantsTableTableOrderingComposer,
    $$PlantsTableTableAnnotationComposer,
    $$PlantsTableTableCreateCompanionBuilder,
    $$PlantsTableTableUpdateCompanionBuilder,
    (PlantsTableData, $$PlantsTableTableReferences),
    PlantsTableData,
    PrefetchHooks Function(
        {bool speciesId,
        bool soilType,
        bool locationId,
        bool entriesTableRefs})>;
typedef $$EntriesTableTableCreateCompanionBuilder = EntriesTableCompanion
    Function({
  required String id,
  required String plantId,
  required DateTime date,
  Value<String?> photoPath,
  Value<String?> note,
  required EntryType type,
  required DateTime createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});
typedef $$EntriesTableTableUpdateCompanionBuilder = EntriesTableCompanion
    Function({
  Value<String> id,
  Value<String> plantId,
  Value<DateTime> date,
  Value<String?> photoPath,
  Value<String?> note,
  Value<EntryType> type,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$EntriesTableTableReferences extends BaseReferences<_$AppDatabase,
    $EntriesTableTable, EntriesTableData> {
  $$EntriesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlantsTableTable _plantIdTable(_$AppDatabase db) =>
      db.plantsTable.createAlias(
          $_aliasNameGenerator(db.entriesTable.plantId, db.plantsTable.id));

  $$PlantsTableTableProcessedTableManager get plantId {
    final $_column = $_itemColumn<String>('plant_id')!;

    final manager = $$PlantsTableTableTableManager($_db, $_db.plantsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTableTable> {
  $$EntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EntryType, EntryType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$PlantsTableTableFilterComposer get plantId {
    final $$PlantsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableFilterComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTableTable> {
  $$EntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$PlantsTableTableOrderingComposer get plantId {
    final $$PlantsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableOrderingComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTableTable> {
  $$EntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EntryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  $$PlantsTableTableAnnotationComposer get plantId {
    final $$PlantsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.plantsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.plantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EntriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntriesTableTable,
    EntriesTableData,
    $$EntriesTableTableFilterComposer,
    $$EntriesTableTableOrderingComposer,
    $$EntriesTableTableAnnotationComposer,
    $$EntriesTableTableCreateCompanionBuilder,
    $$EntriesTableTableUpdateCompanionBuilder,
    (EntriesTableData, $$EntriesTableTableReferences),
    EntriesTableData,
    PrefetchHooks Function({bool plantId})> {
  $$EntriesTableTableTableManager(_$AppDatabase db, $EntriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> plantId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<EntryType> type = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesTableCompanion(
            id: id,
            plantId: plantId,
            date: date,
            photoPath: photoPath,
            note: note,
            type: type,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String plantId,
            required DateTime date,
            Value<String?> photoPath = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required EntryType type,
            required DateTime createdAt,
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesTableCompanion.insert(
            id: id,
            plantId: plantId,
            date: date,
            photoPath: photoPath,
            note: note,
            type: type,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EntriesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({plantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (plantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.plantId,
                    referencedTable:
                        $$EntriesTableTableReferences._plantIdTable(db),
                    referencedColumn:
                        $$EntriesTableTableReferences._plantIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EntriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntriesTableTable,
    EntriesTableData,
    $$EntriesTableTableFilterComposer,
    $$EntriesTableTableOrderingComposer,
    $$EntriesTableTableAnnotationComposer,
    $$EntriesTableTableCreateCompanionBuilder,
    $$EntriesTableTableUpdateCompanionBuilder,
    (EntriesTableData, $$EntriesTableTableReferences),
    EntriesTableData,
    PrefetchHooks Function({bool plantId})>;
typedef $$SyncQueueTableTableCreateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String operation,
  required String payload,
  Value<bool> processed,
  required DateTime createdAt,
});
typedef $$SyncQueueTableTableUpdateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payload,
  Value<bool> processed,
  Value<DateTime> createdAt,
});

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get processed => $composableBuilder(
      column: $table.processed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get processed => $composableBuilder(
      column: $table.processed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get processed =>
      $composableBuilder(column: $table.processed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueTableData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueTableData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>
    ),
    SyncQueueTableData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableTableManager(
      _$AppDatabase db, $SyncQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<bool> processed = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueueTableCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            processed: processed,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String operation,
            required String payload,
            Value<bool> processed = const Value.absent(),
            required DateTime createdAt,
          }) =>
              SyncQueueTableCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            processed: processed,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueTableData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueTableData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>
    ),
    SyncQueueTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db, _db.speciesTable);
  $$SoilsTableTableTableManager get soilsTable =>
      $$SoilsTableTableTableManager(_db, _db.soilsTable);
  $$LocationsTableTableTableManager get locationsTable =>
      $$LocationsTableTableTableManager(_db, _db.locationsTable);
  $$PlantsTableTableTableManager get plantsTable =>
      $$PlantsTableTableTableManager(_db, _db.plantsTable);
  $$EntriesTableTableTableManager get entriesTable =>
      $$EntriesTableTableTableManager(_db, _db.entriesTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
}
