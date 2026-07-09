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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localRevMeta =
      const VerificationMeta('localRev');
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
      'local_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scientificName,
        popularName,
        defaultIrrigationFrequencyDays,
        recommendedSoilTypes,
        createdAt,
        updatedAt,
        deletedAt,
        localRev
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
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('local_rev')) {
      context.handle(_localRevMeta,
          localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta));
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
    );
  }

  @override
  $SpeciesTableTable createAlias(String alias) {
    return $SpeciesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterrecommendedSoilTypes =
      const StringListConverter();
}

class SpeciesTableData extends DataClass
    implements Insertable<SpeciesTableData> {
  final String id;
  final String scientificName;
  final String popularName;
  final int? defaultIrrigationFrequencyDays;

  /// JSON-encoded list of soil IDs
  final List<String> recommendedSoilTypes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  const SpeciesTableData(
      {required this.id,
      required this.scientificName,
      required this.popularName,
      this.defaultIrrigationFrequencyDays,
      required this.recommendedSoilTypes,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev});
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
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
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
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
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
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
    };
  }

  SpeciesTableData copyWith(
          {String? id,
          String? scientificName,
          String? popularName,
          Value<int?> defaultIrrigationFrequencyDays = const Value.absent(),
          List<String>? recommendedSoilTypes,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev}) =>
      SpeciesTableData(
        id: id ?? this.id,
        scientificName: scientificName ?? this.scientificName,
        popularName: popularName ?? this.popularName,
        defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays.present
            ? defaultIrrigationFrequencyDays.value
            : this.defaultIrrigationFrequencyDays,
        recommendedSoilTypes: recommendedSoilTypes ?? this.recommendedSoilTypes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
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
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev')
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
      createdAt,
      updatedAt,
      deletedAt,
      localRev);
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
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev);
}

class SpeciesTableCompanion extends UpdateCompanion<SpeciesTableData> {
  final Value<String> id;
  final Value<String> scientificName;
  final Value<String> popularName;
  final Value<int?> defaultIrrigationFrequencyDays;
  final Value<List<String>> recommendedSoilTypes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int> rowid;
  const SpeciesTableCompanion({
    this.id = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.popularName = const Value.absent(),
    this.defaultIrrigationFrequencyDays = const Value.absent(),
    this.recommendedSoilTypes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeciesTableCompanion.insert({
    required String id,
    required String scientificName,
    required String popularName,
    this.defaultIrrigationFrequencyDays = const Value.absent(),
    required List<String> recommendedSoilTypes,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        scientificName = Value(scientificName),
        popularName = Value(popularName),
        recommendedSoilTypes = Value(recommendedSoilTypes),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SpeciesTableData> custom({
    Expression<String>? id,
    Expression<String>? scientificName,
    Expression<String>? popularName,
    Expression<int>? defaultIrrigationFrequencyDays,
    Expression<String>? recommendedSoilTypes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
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
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeciesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? scientificName,
      Value<String>? popularName,
      Value<int?>? defaultIrrigationFrequencyDays,
      Value<List<String>>? recommendedSoilTypes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<int>? rowid}) {
    return SpeciesTableCompanion(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      popularName: popularName ?? this.popularName,
      defaultIrrigationFrequencyDays:
          defaultIrrigationFrequencyDays ?? this.defaultIrrigationFrequencyDays,
      recommendedSoilTypes: recommendedSoilTypes ?? this.recommendedSoilTypes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
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
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageSourceMeta =
      const VerificationMeta('imageSource');
  @override
  late final GeneratedColumn<String> imageSource = GeneratedColumn<String>(
      'image_source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localRevMeta =
      const VerificationMeta('localRev');
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
      'local_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isSeededMeta =
      const VerificationMeta('isSeeded');
  @override
  late final GeneratedColumn<bool> isSeeded = GeneratedColumn<bool>(
      'is_seeded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_seeded" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        composition,
        imagePath,
        imageSource,
        createdAt,
        updatedAt,
        deletedAt,
        localRev,
        isSeeded
      ];
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
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('image_source')) {
      context.handle(
          _imageSourceMeta,
          imageSource.isAcceptableOrUnknown(
              data['image_source']!, _imageSourceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('local_rev')) {
      context.handle(_localRevMeta,
          localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta));
    }
    if (data.containsKey('is_seeded')) {
      context.handle(_isSeededMeta,
          isSeeded.isAcceptableOrUnknown(data['is_seeded']!, _isSeededMeta));
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
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      imageSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_source']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
      isSeeded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_seeded'])!,
    );
  }

  @override
  $SoilsTableTable createAlias(String alias) {
    return $SoilsTableTable(attachedDatabase, alias);
  }
}

class SoilsTableData extends DataClass implements Insertable<SoilsTableData> {
  final String id;
  final String name;
  final String? composition;
  final String? imagePath;
  final String? imageSource;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

  /// True for the default soils seeded on database creation/upgrade (see
  /// app_database.dart), false for soils the user created. Distinguishes
  /// "never touched by the user" from "genuinely local-only data worth
  /// migrating" in WorkspaceMigrationService, now that there's no
  /// syncStatus column to repurpose for that check.
  final bool isSeeded;
  const SoilsTableData(
      {required this.id,
      required this.name,
      this.composition,
      this.imagePath,
      this.imageSource,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev,
      required this.isSeeded});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || composition != null) {
      map['composition'] = Variable<String>(composition);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || imageSource != null) {
      map['image_source'] = Variable<String>(imageSource);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    map['is_seeded'] = Variable<bool>(isSeeded);
    return map;
  }

  SoilsTableCompanion toCompanion(bool nullToAbsent) {
    return SoilsTableCompanion(
      id: Value(id),
      name: Value(name),
      composition: composition == null && nullToAbsent
          ? const Value.absent()
          : Value(composition),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      imageSource: imageSource == null && nullToAbsent
          ? const Value.absent()
          : Value(imageSource),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      isSeeded: Value(isSeeded),
    );
  }

  factory SoilsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SoilsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      composition: serializer.fromJson<String?>(json['composition']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      imageSource: serializer.fromJson<String?>(json['imageSource']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      isSeeded: serializer.fromJson<bool>(json['isSeeded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'composition': serializer.toJson<String?>(composition),
      'imagePath': serializer.toJson<String?>(imagePath),
      'imageSource': serializer.toJson<String?>(imageSource),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'isSeeded': serializer.toJson<bool>(isSeeded),
    };
  }

  SoilsTableData copyWith(
          {String? id,
          String? name,
          Value<String?> composition = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<String?> imageSource = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev,
          bool? isSeeded}) =>
      SoilsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        composition: composition.present ? composition.value : this.composition,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        imageSource: imageSource.present ? imageSource.value : this.imageSource,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
        isSeeded: isSeeded ?? this.isSeeded,
      );
  SoilsTableData copyWithCompanion(SoilsTableCompanion data) {
    return SoilsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      composition:
          data.composition.present ? data.composition.value : this.composition,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      imageSource:
          data.imageSource.present ? data.imageSource.value : this.imageSource,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      isSeeded: data.isSeeded.present ? data.isSeeded.value : this.isSeeded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SoilsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('composition: $composition, ')
          ..write('imagePath: $imagePath, ')
          ..write('imageSource: $imageSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('isSeeded: $isSeeded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, composition, imagePath, imageSource,
      createdAt, updatedAt, deletedAt, localRev, isSeeded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SoilsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.composition == this.composition &&
          other.imagePath == this.imagePath &&
          other.imageSource == this.imageSource &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.isSeeded == this.isSeeded);
}

class SoilsTableCompanion extends UpdateCompanion<SoilsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> composition;
  final Value<String?> imagePath;
  final Value<String?> imageSource;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<bool> isSeeded;
  final Value<int> rowid;
  const SoilsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.composition = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.imageSource = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.isSeeded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SoilsTableCompanion.insert({
    required String id,
    required String name,
    this.composition = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.imageSource = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.isSeeded = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SoilsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? composition,
    Expression<String>? imagePath,
    Expression<String>? imageSource,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<bool>? isSeeded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (composition != null) 'composition': composition,
      if (imagePath != null) 'image_path': imagePath,
      if (imageSource != null) 'image_source': imageSource,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (isSeeded != null) 'is_seeded': isSeeded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SoilsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? composition,
      Value<String?>? imagePath,
      Value<String?>? imageSource,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<bool>? isSeeded,
      Value<int>? rowid}) {
    return SoilsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      composition: composition ?? this.composition,
      imagePath: imagePath ?? this.imagePath,
      imageSource: imageSource ?? this.imageSource,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      isSeeded: isSeeded ?? this.isSeeded,
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
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (imageSource.present) {
      map['image_source'] = Variable<String>(imageSource.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (isSeeded.present) {
      map['is_seeded'] = Variable<bool>(isSeeded.value);
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
          ..write('imagePath: $imagePath, ')
          ..write('imageSource: $imageSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('isSeeded: $isSeeded, ')
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localRevMeta =
      const VerificationMeta('localRev');
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
      'local_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        latitude,
        longitude,
        createdAt,
        updatedAt,
        deletedAt,
        localRev
      ];
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
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('local_rev')) {
      context.handle(_localRevMeta,
          localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta));
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
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
    );
  }

  @override
  $LocationsTableTable createAlias(String alias) {
    return $LocationsTableTable(attachedDatabase, alias);
  }
}

class LocationsTableData extends DataClass
    implements Insertable<LocationsTableData> {
  final String id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  const LocationsTableData(
      {required this.id,
      required this.name,
      this.description,
      this.latitude,
      this.longitude,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev});
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
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
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
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
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
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
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
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
    };
  }

  LocationsTableData copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev}) =>
      LocationsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
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
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, latitude, longitude,
      createdAt, updatedAt, deletedAt, localRev);
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
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev);
}

class LocationsTableCompanion extends UpdateCompanion<LocationsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int> rowid;
  const LocationsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocationsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
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
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<int>? rowid}) {
    return LocationsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localRevMeta =
      const VerificationMeta('localRev');
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
      'local_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
        updatedAt,
        deletedAt,
        localRev
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
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('local_rev')) {
      context.handle(_localRevMeta,
          localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta));
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
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
    );
  }

  @override
  $PlantsTableTable createAlias(String alias) {
    return $PlantsTableTable(attachedDatabase, alias);
  }
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
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
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
      required this.updatedAt,
      this.deletedAt,
      required this.localRev});
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
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
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
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
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
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
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
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
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
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev}) =>
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
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
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
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev')
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
      updatedAt,
      deletedAt,
      localRev);
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
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev);
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
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
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
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
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
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        speciesId = Value(speciesId),
        nickname = Value(nickname),
        soilType = Value(soilType),
        acquisitionDate = Value(acquisitionDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
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
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
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
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
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
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
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
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
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
  static const VerificationMeta _numericValueMeta =
      const VerificationMeta('numericValue');
  @override
  late final GeneratedColumn<double> numericValue = GeneratedColumn<double>(
      'numeric_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _extraDataMeta =
      const VerificationMeta('extraData');
  @override
  late final GeneratedColumn<String> extraData = GeneratedColumn<String>(
      'extra_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localRevMeta =
      const VerificationMeta('localRev');
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
      'local_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        plantId,
        date,
        photoPath,
        note,
        type,
        numericValue,
        extraData,
        createdAt,
        updatedAt,
        deletedAt,
        localRev
      ];
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
    if (data.containsKey('numeric_value')) {
      context.handle(
          _numericValueMeta,
          numericValue.isAcceptableOrUnknown(
              data['numeric_value']!, _numericValueMeta));
    }
    if (data.containsKey('extra_data')) {
      context.handle(_extraDataMeta,
          extraData.isAcceptableOrUnknown(data['extra_data']!, _extraDataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('local_rev')) {
      context.handle(_localRevMeta,
          localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta));
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
      numericValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}numeric_value']),
      extraData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extra_data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
    );
  }

  @override
  $EntriesTableTable createAlias(String alias) {
    return $EntriesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<EntryType, String> $convertertype =
      const EntryTypeConverter();
}

class EntriesTableData extends DataClass
    implements Insertable<EntriesTableData> {
  final String id;
  final String plantId;
  final DateTime date;
  final String? photoPath;
  final String? note;
  final EntryType type;
  final double? numericValue;
  final String? extraData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  const EntriesTableData(
      {required this.id,
      required this.plantId,
      required this.date,
      this.photoPath,
      this.note,
      required this.type,
      this.numericValue,
      this.extraData,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev});
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
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<double>(numericValue);
    }
    if (!nullToAbsent || extraData != null) {
      map['extra_data'] = Variable<String>(extraData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
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
      numericValue: numericValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numericValue),
      extraData: extraData == null && nullToAbsent
          ? const Value.absent()
          : Value(extraData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
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
      numericValue: serializer.fromJson<double?>(json['numericValue']),
      extraData: serializer.fromJson<String?>(json['extraData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
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
      'numericValue': serializer.toJson<double?>(numericValue),
      'extraData': serializer.toJson<String?>(extraData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
    };
  }

  EntriesTableData copyWith(
          {String? id,
          String? plantId,
          DateTime? date,
          Value<String?> photoPath = const Value.absent(),
          Value<String?> note = const Value.absent(),
          EntryType? type,
          Value<double?> numericValue = const Value.absent(),
          Value<String?> extraData = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev}) =>
      EntriesTableData(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        date: date ?? this.date,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        note: note.present ? note.value : this.note,
        type: type ?? this.type,
        numericValue:
            numericValue.present ? numericValue.value : this.numericValue,
        extraData: extraData.present ? extraData.value : this.extraData,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
      );
  EntriesTableData copyWithCompanion(EntriesTableCompanion data) {
    return EntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      date: data.date.present ? data.date.value : this.date,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      note: data.note.present ? data.note.value : this.note,
      type: data.type.present ? data.type.value : this.type,
      numericValue: data.numericValue.present
          ? data.numericValue.value
          : this.numericValue,
      extraData: data.extraData.present ? data.extraData.value : this.extraData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
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
          ..write('numericValue: $numericValue, ')
          ..write('extraData: $extraData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, date, photoPath, note, type,
      numericValue, extraData, createdAt, updatedAt, deletedAt, localRev);
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
          other.numericValue == this.numericValue &&
          other.extraData == this.extraData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev);
}

class EntriesTableCompanion extends UpdateCompanion<EntriesTableData> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<DateTime> date;
  final Value<String?> photoPath;
  final Value<String?> note;
  final Value<EntryType> type;
  final Value<double?> numericValue;
  final Value<String?> extraData;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int> rowid;
  const EntriesTableCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.date = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.note = const Value.absent(),
    this.type = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.extraData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesTableCompanion.insert({
    required String id,
    required String plantId,
    required DateTime date,
    this.photoPath = const Value.absent(),
    this.note = const Value.absent(),
    required EntryType type,
    this.numericValue = const Value.absent(),
    this.extraData = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        plantId = Value(plantId),
        date = Value(date),
        type = Value(type),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<EntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<DateTime>? date,
    Expression<String>? photoPath,
    Expression<String>? note,
    Expression<String>? type,
    Expression<double>? numericValue,
    Expression<String>? extraData,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (date != null) 'date': date,
      if (photoPath != null) 'photo_path': photoPath,
      if (note != null) 'note': note,
      if (type != null) 'type': type,
      if (numericValue != null) 'numeric_value': numericValue,
      if (extraData != null) 'extra_data': extraData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
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
      Value<double?>? numericValue,
      Value<String?>? extraData,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<int>? rowid}) {
    return EntriesTableCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      date: date ?? this.date,
      photoPath: photoPath ?? this.photoPath,
      note: note ?? this.note,
      type: type ?? this.type,
      numericValue: numericValue ?? this.numericValue,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
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
    if (numericValue.present) {
      map['numeric_value'] = Variable<double>(numericValue.value);
    }
    if (extraData.present) {
      map['extra_data'] = Variable<String>(extraData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
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
          ..write('numericValue: $numericValue, ')
          ..write('extraData: $extraData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTableTable extends SyncMetaTable
    with TableInfo<$SyncMetaTableTable, SyncMetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nextLocalRevMeta =
      const VerificationMeta('nextLocalRev');
  @override
  late final GeneratedColumn<int> nextLocalRev = GeneratedColumn<int>(
      'next_local_rev', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [id, nextLocalRev];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetaTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('next_local_rev')) {
      context.handle(
          _nextLocalRevMeta,
          nextLocalRev.isAcceptableOrUnknown(
              data['next_local_rev']!, _nextLocalRevMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nextLocalRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}next_local_rev'])!,
    );
  }

  @override
  $SyncMetaTableTable createAlias(String alias) {
    return $SyncMetaTableTable(attachedDatabase, alias);
  }
}

class SyncMetaTableData extends DataClass
    implements Insertable<SyncMetaTableData> {
  final int id;
  final int nextLocalRev;
  const SyncMetaTableData({required this.id, required this.nextLocalRev});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['next_local_rev'] = Variable<int>(nextLocalRev);
    return map;
  }

  SyncMetaTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaTableCompanion(
      id: Value(id),
      nextLocalRev: Value(nextLocalRev),
    );
  }

  factory SyncMetaTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaTableData(
      id: serializer.fromJson<int>(json['id']),
      nextLocalRev: serializer.fromJson<int>(json['nextLocalRev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nextLocalRev': serializer.toJson<int>(nextLocalRev),
    };
  }

  SyncMetaTableData copyWith({int? id, int? nextLocalRev}) => SyncMetaTableData(
        id: id ?? this.id,
        nextLocalRev: nextLocalRev ?? this.nextLocalRev,
      );
  SyncMetaTableData copyWithCompanion(SyncMetaTableCompanion data) {
    return SyncMetaTableData(
      id: data.id.present ? data.id.value : this.id,
      nextLocalRev: data.nextLocalRev.present
          ? data.nextLocalRev.value
          : this.nextLocalRev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableData(')
          ..write('id: $id, ')
          ..write('nextLocalRev: $nextLocalRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nextLocalRev);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaTableData &&
          other.id == this.id &&
          other.nextLocalRev == this.nextLocalRev);
}

class SyncMetaTableCompanion extends UpdateCompanion<SyncMetaTableData> {
  final Value<int> id;
  final Value<int> nextLocalRev;
  const SyncMetaTableCompanion({
    this.id = const Value.absent(),
    this.nextLocalRev = const Value.absent(),
  });
  SyncMetaTableCompanion.insert({
    this.id = const Value.absent(),
    this.nextLocalRev = const Value.absent(),
  });
  static Insertable<SyncMetaTableData> custom({
    Expression<int>? id,
    Expression<int>? nextLocalRev,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nextLocalRev != null) 'next_local_rev': nextLocalRev,
    });
  }

  SyncMetaTableCompanion copyWith({Value<int>? id, Value<int>? nextLocalRev}) {
    return SyncMetaTableCompanion(
      id: id ?? this.id,
      nextLocalRev: nextLocalRev ?? this.nextLocalRev,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nextLocalRev.present) {
      map['next_local_rev'] = Variable<int>(nextLocalRev.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaTableCompanion(')
          ..write('id: $id, ')
          ..write('nextLocalRev: $nextLocalRev')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTableTable extends SyncCursorsTable
    with TableInfo<$SyncCursorsTableTable, SyncCursorsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
      'cursor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [peerId, direction, cursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncCursorsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta,
          cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerId, direction};
  @override
  SyncCursorsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorsTableData(
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      cursor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cursor'])!,
    );
  }

  @override
  $SyncCursorsTableTable createAlias(String alias) {
    return $SyncCursorsTableTable(attachedDatabase, alias);
  }
}

class SyncCursorsTableData extends DataClass
    implements Insertable<SyncCursorsTableData> {
  final String peerId;

  /// 'pull' | 'push'
  final String direction;
  final int cursor;
  const SyncCursorsTableData(
      {required this.peerId, required this.direction, required this.cursor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_id'] = Variable<String>(peerId);
    map['direction'] = Variable<String>(direction);
    map['cursor'] = Variable<int>(cursor);
    return map;
  }

  SyncCursorsTableCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsTableCompanion(
      peerId: Value(peerId),
      direction: Value(direction),
      cursor: Value(cursor),
    );
  }

  factory SyncCursorsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorsTableData(
      peerId: serializer.fromJson<String>(json['peerId']),
      direction: serializer.fromJson<String>(json['direction']),
      cursor: serializer.fromJson<int>(json['cursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerId': serializer.toJson<String>(peerId),
      'direction': serializer.toJson<String>(direction),
      'cursor': serializer.toJson<int>(cursor),
    };
  }

  SyncCursorsTableData copyWith(
          {String? peerId, String? direction, int? cursor}) =>
      SyncCursorsTableData(
        peerId: peerId ?? this.peerId,
        direction: direction ?? this.direction,
        cursor: cursor ?? this.cursor,
      );
  SyncCursorsTableData copyWithCompanion(SyncCursorsTableCompanion data) {
    return SyncCursorsTableData(
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
      direction: data.direction.present ? data.direction.value : this.direction,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsTableData(')
          ..write('peerId: $peerId, ')
          ..write('direction: $direction, ')
          ..write('cursor: $cursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(peerId, direction, cursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorsTableData &&
          other.peerId == this.peerId &&
          other.direction == this.direction &&
          other.cursor == this.cursor);
}

class SyncCursorsTableCompanion extends UpdateCompanion<SyncCursorsTableData> {
  final Value<String> peerId;
  final Value<String> direction;
  final Value<int> cursor;
  final Value<int> rowid;
  const SyncCursorsTableCompanion({
    this.peerId = const Value.absent(),
    this.direction = const Value.absent(),
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsTableCompanion.insert({
    required String peerId,
    required String direction,
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : peerId = Value(peerId),
        direction = Value(direction);
  static Insertable<SyncCursorsTableData> custom({
    Expression<String>? peerId,
    Expression<String>? direction,
    Expression<int>? cursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerId != null) 'peer_id': peerId,
      if (direction != null) 'direction': direction,
      if (cursor != null) 'cursor': cursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsTableCompanion copyWith(
      {Value<String>? peerId,
      Value<String>? direction,
      Value<int>? cursor,
      Value<int>? rowid}) {
    return SyncCursorsTableCompanion(
      peerId: peerId ?? this.peerId,
      direction: direction ?? this.direction,
      cursor: cursor ?? this.cursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsTableCompanion(')
          ..write('peerId: $peerId, ')
          ..write('direction: $direction, ')
          ..write('cursor: $cursor, ')
          ..write('rowid: $rowid')
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
  late final $SyncMetaTableTable syncMetaTable = $SyncMetaTableTable(this);
  late final $SyncCursorsTableTable syncCursorsTable =
      $SyncCursorsTableTable(this);
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
        syncMetaTable,
        syncCursorsTable
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
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<int> rowid,
});
typedef $$SpeciesTableTableUpdateCompanionBuilder = SpeciesTableCompanion
    Function({
  Value<String> id,
  Value<String> scientificName,
  Value<String> popularName,
  Value<int?> defaultIrrigationFrequencyDays,
  Value<List<String>> recommendedSoilTypes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<int> rowid,
});

final class $$SpeciesTableTableReferences extends BaseReferences<_$AppDatabase,
    $SpeciesTableTable, SpeciesTableData> {
  $$SpeciesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTableTable, List<PlantsTableData>>
      _plantsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plantsTable,
              aliasName: 'species__id__plants__species_id');

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpeciesTableCompanion(
            id: id,
            scientificName: scientificName,
            popularName: popularName,
            defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays,
            recommendedSoilTypes: recommendedSoilTypes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String scientificName,
            required String popularName,
            Value<int?> defaultIrrigationFrequencyDays = const Value.absent(),
            required List<String> recommendedSoilTypes,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpeciesTableCompanion.insert(
            id: id,
            scientificName: scientificName,
            popularName: popularName,
            defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays,
            recommendedSoilTypes: recommendedSoilTypes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
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
  Value<String?> imagePath,
  Value<String?> imageSource,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<bool> isSeeded,
  Value<int> rowid,
});
typedef $$SoilsTableTableUpdateCompanionBuilder = SoilsTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> composition,
  Value<String?> imagePath,
  Value<String?> imageSource,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<bool> isSeeded,
  Value<int> rowid,
});

final class $$SoilsTableTableReferences
    extends BaseReferences<_$AppDatabase, $SoilsTableTable, SoilsTableData> {
  $$SoilsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTableTable, List<PlantsTableData>>
      _plantsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plantsTable,
              aliasName: 'soils__id__plants__soil_type');

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

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageSource => $composableBuilder(
      column: $table.imageSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSeeded => $composableBuilder(
      column: $table.isSeeded, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageSource => $composableBuilder(
      column: $table.imageSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSeeded => $composableBuilder(
      column: $table.isSeeded, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get imageSource => $composableBuilder(
      column: $table.imageSource, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<bool> get isSeeded =>
      $composableBuilder(column: $table.isSeeded, builder: (column) => column);

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
            Value<String?> imagePath = const Value.absent(),
            Value<String?> imageSource = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<bool> isSeeded = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SoilsTableCompanion(
            id: id,
            name: name,
            composition: composition,
            imagePath: imagePath,
            imageSource: imageSource,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            isSeeded: isSeeded,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> composition = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> imageSource = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<bool> isSeeded = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SoilsTableCompanion.insert(
            id: id,
            name: name,
            composition: composition,
            imagePath: imagePath,
            imageSource: imageSource,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            isSeeded: isSeeded,
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
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
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
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<int> rowid,
});

final class $$LocationsTableTableReferences extends BaseReferences<
    _$AppDatabase, $LocationsTableTable, LocationsTableData> {
  $$LocationsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantsTableTable, List<PlantsTableData>>
      _plantsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plantsTable,
              aliasName: 'locations__id__plants__location_id');

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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

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
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsTableCompanion(
            id: id,
            name: name,
            description: description,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsTableCompanion.insert(
            id: id,
            name: name,
            description: description,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
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
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
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
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<int> rowid,
});

final class $$PlantsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PlantsTableTable, PlantsTableData> {
  $$PlantsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpeciesTableTable _speciesIdTable(_$AppDatabase db) =>
      db.speciesTable.createAlias('plants__species_id__species__id');

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
      db.soilsTable.createAlias('plants__soil_type__soils__id');

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
      db.locationsTable.createAlias('plants__location_id__locations__id');

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
      _entriesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.entriesTable,
              aliasName: 'plants__id__entries__plant_id');

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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

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
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
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
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
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
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
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
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
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
  Value<double?> numericValue,
  Value<String?> extraData,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
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
  Value<double?> numericValue,
  Value<String?> extraData,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<int> rowid,
});

final class $$EntriesTableTableReferences extends BaseReferences<_$AppDatabase,
    $EntriesTableTable, EntriesTableData> {
  $$EntriesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlantsTableTable _plantIdTable(_$AppDatabase db) =>
      db.plantsTable.createAlias('entries__plant_id__plants__id');

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

  ColumnFilters<double> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extraData => $composableBuilder(
      column: $table.extraData, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<double> get numericValue => $composableBuilder(
      column: $table.numericValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extraData => $composableBuilder(
      column: $table.extraData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<double> get numericValue => $composableBuilder(
      column: $table.numericValue, builder: (column) => column);

  GeneratedColumn<String> get extraData =>
      $composableBuilder(column: $table.extraData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

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
            Value<double?> numericValue = const Value.absent(),
            Value<String?> extraData = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesTableCompanion(
            id: id,
            plantId: plantId,
            date: date,
            photoPath: photoPath,
            note: note,
            type: type,
            numericValue: numericValue,
            extraData: extraData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String plantId,
            required DateTime date,
            Value<String?> photoPath = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required EntryType type,
            Value<double?> numericValue = const Value.absent(),
            Value<String?> extraData = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesTableCompanion.insert(
            id: id,
            plantId: plantId,
            date: date,
            photoPath: photoPath,
            note: note,
            type: type,
            numericValue: numericValue,
            extraData: extraData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
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
typedef $$SyncMetaTableTableCreateCompanionBuilder = SyncMetaTableCompanion
    Function({
  Value<int> id,
  Value<int> nextLocalRev,
});
typedef $$SyncMetaTableTableUpdateCompanionBuilder = SyncMetaTableCompanion
    Function({
  Value<int> id,
  Value<int> nextLocalRev,
});

class $$SyncMetaTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nextLocalRev => $composableBuilder(
      column: $table.nextLocalRev, builder: (column) => ColumnFilters(column));
}

class $$SyncMetaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nextLocalRev => $composableBuilder(
      column: $table.nextLocalRev,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncMetaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTableTable> {
  $$SyncMetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nextLocalRev => $composableBuilder(
      column: $table.nextLocalRev, builder: (column) => column);
}

class $$SyncMetaTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetaTableTable,
    SyncMetaTableData,
    $$SyncMetaTableTableFilterComposer,
    $$SyncMetaTableTableOrderingComposer,
    $$SyncMetaTableTableAnnotationComposer,
    $$SyncMetaTableTableCreateCompanionBuilder,
    $$SyncMetaTableTableUpdateCompanionBuilder,
    (
      SyncMetaTableData,
      BaseReferences<_$AppDatabase, $SyncMetaTableTable, SyncMetaTableData>
    ),
    SyncMetaTableData,
    PrefetchHooks Function()> {
  $$SyncMetaTableTableTableManager(_$AppDatabase db, $SyncMetaTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> nextLocalRev = const Value.absent(),
          }) =>
              SyncMetaTableCompanion(
            id: id,
            nextLocalRev: nextLocalRev,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> nextLocalRev = const Value.absent(),
          }) =>
              SyncMetaTableCompanion.insert(
            id: id,
            nextLocalRev: nextLocalRev,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetaTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetaTableTable,
    SyncMetaTableData,
    $$SyncMetaTableTableFilterComposer,
    $$SyncMetaTableTableOrderingComposer,
    $$SyncMetaTableTableAnnotationComposer,
    $$SyncMetaTableTableCreateCompanionBuilder,
    $$SyncMetaTableTableUpdateCompanionBuilder,
    (
      SyncMetaTableData,
      BaseReferences<_$AppDatabase, $SyncMetaTableTable, SyncMetaTableData>
    ),
    SyncMetaTableData,
    PrefetchHooks Function()>;
typedef $$SyncCursorsTableTableCreateCompanionBuilder
    = SyncCursorsTableCompanion Function({
  required String peerId,
  required String direction,
  Value<int> cursor,
  Value<int> rowid,
});
typedef $$SyncCursorsTableTableUpdateCompanionBuilder
    = SyncCursorsTableCompanion Function({
  Value<String> peerId,
  Value<String> direction,
  Value<int> cursor,
  Value<int> rowid,
});

class $$SyncCursorsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTableTable> {
  $$SyncCursorsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTableTable> {
  $$SyncCursorsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTableTable> {
  $$SyncCursorsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);
}

class $$SyncCursorsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncCursorsTableTable,
    SyncCursorsTableData,
    $$SyncCursorsTableTableFilterComposer,
    $$SyncCursorsTableTableOrderingComposer,
    $$SyncCursorsTableTableAnnotationComposer,
    $$SyncCursorsTableTableCreateCompanionBuilder,
    $$SyncCursorsTableTableUpdateCompanionBuilder,
    (
      SyncCursorsTableData,
      BaseReferences<_$AppDatabase, $SyncCursorsTableTable,
          SyncCursorsTableData>
    ),
    SyncCursorsTableData,
    PrefetchHooks Function()> {
  $$SyncCursorsTableTableTableManager(
      _$AppDatabase db, $SyncCursorsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> peerId = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<int> cursor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsTableCompanion(
            peerId: peerId,
            direction: direction,
            cursor: cursor,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String peerId,
            required String direction,
            Value<int> cursor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsTableCompanion.insert(
            peerId: peerId,
            direction: direction,
            cursor: cursor,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncCursorsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncCursorsTableTable,
    SyncCursorsTableData,
    $$SyncCursorsTableTableFilterComposer,
    $$SyncCursorsTableTableOrderingComposer,
    $$SyncCursorsTableTableAnnotationComposer,
    $$SyncCursorsTableTableCreateCompanionBuilder,
    $$SyncCursorsTableTableUpdateCompanionBuilder,
    (
      SyncCursorsTableData,
      BaseReferences<_$AppDatabase, $SyncCursorsTableTable,
          SyncCursorsTableData>
    ),
    SyncCursorsTableData,
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
  $$SyncMetaTableTableTableManager get syncMetaTable =>
      $$SyncMetaTableTableTableManager(_db, _db.syncMetaTable);
  $$SyncCursorsTableTableTableManager get syncCursorsTable =>
      $$SyncCursorsTableTableTableManager(_db, _db.syncCursorsTable);
}
