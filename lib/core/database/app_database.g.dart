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
  late final GeneratedColumnWithTypeConverter<LightRequirement?, String> light =
      GeneratedColumn<String>('light', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<LightRequirement?>($SpeciesTableTable.$converterlight);
  @override
  late final GeneratedColumnWithTypeConverter<HumidityLevel?, String> humidity =
      GeneratedColumn<String>('humidity', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<HumidityLevel?>($SpeciesTableTable.$converterhumidity);
  @override
  late final GeneratedColumnWithTypeConverter<PetToxicity, String> petToxicity =
      GeneratedColumn<String>('pet_toxicity', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('unknown'))
          .withConverter<PetToxicity>($SpeciesTableTable.$converterpetToxicity);
  @override
  late final GeneratedColumnWithTypeConverter<Set<int>, int> floweringMonths =
      GeneratedColumn<int>('flowering_months', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<Set<int>>(
              $SpeciesTableTable.$converterfloweringMonths);
  static const VerificationMeta _careNotesMeta =
      const VerificationMeta('careNotes');
  @override
  late final GeneratedColumn<String> careNotes = GeneratedColumn<String>(
      'care_notes', aliasedName, true,
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scientificName,
        popularName,
        defaultIrrigationFrequencyDays,
        recommendedSoilTypes,
        light,
        humidity,
        petToxicity,
        floweringMonths,
        careNotes,
        createdAt,
        updatedAt,
        deletedAt,
        localRev,
        deviceId
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
    if (data.containsKey('care_notes')) {
      context.handle(_careNotesMeta,
          careNotes.isAcceptableOrUnknown(data['care_notes']!, _careNotesMeta));
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
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
      light: $SpeciesTableTable.$converterlight.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}light'])),
      humidity: $SpeciesTableTable.$converterhumidity.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}humidity'])),
      petToxicity: $SpeciesTableTable.$converterpetToxicity.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}pet_toxicity'])!),
      floweringMonths: $SpeciesTableTable.$converterfloweringMonths.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}flowering_months'])!),
      careNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}care_notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $SpeciesTableTable createAlias(String alias) {
    return $SpeciesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterrecommendedSoilTypes =
      const StringListConverter();
  static TypeConverter<LightRequirement?, String?> $converterlight =
      const LightRequirementConverter();
  static TypeConverter<HumidityLevel?, String?> $converterhumidity =
      const HumidityLevelConverter();
  static TypeConverter<PetToxicity, String> $converterpetToxicity =
      const PetToxicityConverter();
  static TypeConverter<Set<int>, int> $converterfloweringMonths =
      const MonthSetConverter();
}

class SpeciesTableData extends DataClass
    implements Insertable<SpeciesTableData> {
  final String id;
  final String scientificName;
  final String popularName;
  final int? defaultIrrigationFrequencyDays;

  /// JSON-encoded list of soil IDs
  final List<String> recommendedSoilTypes;
  final LightRequirement? light;
  final HumidityLevel? humidity;
  final PetToxicity petToxicity;

  /// Bitmask of flowering months, see [MonthSetConverter].
  final Set<int> floweringMonths;
  final String? careNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final String? deviceId;
  const SpeciesTableData(
      {required this.id,
      required this.scientificName,
      required this.popularName,
      this.defaultIrrigationFrequencyDays,
      required this.recommendedSoilTypes,
      this.light,
      this.humidity,
      required this.petToxicity,
      required this.floweringMonths,
      this.careNotes,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev,
      this.deviceId});
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
    if (!nullToAbsent || light != null) {
      map['light'] =
          Variable<String>($SpeciesTableTable.$converterlight.toSql(light));
    }
    if (!nullToAbsent || humidity != null) {
      map['humidity'] = Variable<String>(
          $SpeciesTableTable.$converterhumidity.toSql(humidity));
    }
    {
      map['pet_toxicity'] = Variable<String>(
          $SpeciesTableTable.$converterpetToxicity.toSql(petToxicity));
    }
    {
      map['flowering_months'] = Variable<int>(
          $SpeciesTableTable.$converterfloweringMonths.toSql(floweringMonths));
    }
    if (!nullToAbsent || careNotes != null) {
      map['care_notes'] = Variable<String>(careNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
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
      light:
          light == null && nullToAbsent ? const Value.absent() : Value(light),
      humidity: humidity == null && nullToAbsent
          ? const Value.absent()
          : Value(humidity),
      petToxicity: Value(petToxicity),
      floweringMonths: Value(floweringMonths),
      careNotes: careNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(careNotes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
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
      light: serializer.fromJson<LightRequirement?>(json['light']),
      humidity: serializer.fromJson<HumidityLevel?>(json['humidity']),
      petToxicity: serializer.fromJson<PetToxicity>(json['petToxicity']),
      floweringMonths: serializer.fromJson<Set<int>>(json['floweringMonths']),
      careNotes: serializer.fromJson<String?>(json['careNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
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
      'light': serializer.toJson<LightRequirement?>(light),
      'humidity': serializer.toJson<HumidityLevel?>(humidity),
      'petToxicity': serializer.toJson<PetToxicity>(petToxicity),
      'floweringMonths': serializer.toJson<Set<int>>(floweringMonths),
      'careNotes': serializer.toJson<String?>(careNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  SpeciesTableData copyWith(
          {String? id,
          String? scientificName,
          String? popularName,
          Value<int?> defaultIrrigationFrequencyDays = const Value.absent(),
          List<String>? recommendedSoilTypes,
          Value<LightRequirement?> light = const Value.absent(),
          Value<HumidityLevel?> humidity = const Value.absent(),
          PetToxicity? petToxicity,
          Set<int>? floweringMonths,
          Value<String?> careNotes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev,
          Value<String?> deviceId = const Value.absent()}) =>
      SpeciesTableData(
        id: id ?? this.id,
        scientificName: scientificName ?? this.scientificName,
        popularName: popularName ?? this.popularName,
        defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays.present
            ? defaultIrrigationFrequencyDays.value
            : this.defaultIrrigationFrequencyDays,
        recommendedSoilTypes: recommendedSoilTypes ?? this.recommendedSoilTypes,
        light: light.present ? light.value : this.light,
        humidity: humidity.present ? humidity.value : this.humidity,
        petToxicity: petToxicity ?? this.petToxicity,
        floweringMonths: floweringMonths ?? this.floweringMonths,
        careNotes: careNotes.present ? careNotes.value : this.careNotes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
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
      light: data.light.present ? data.light.value : this.light,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      petToxicity:
          data.petToxicity.present ? data.petToxicity.value : this.petToxicity,
      floweringMonths: data.floweringMonths.present
          ? data.floweringMonths.value
          : this.floweringMonths,
      careNotes: data.careNotes.present ? data.careNotes.value : this.careNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
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
          ..write('light: $light, ')
          ..write('humidity: $humidity, ')
          ..write('petToxicity: $petToxicity, ')
          ..write('floweringMonths: $floweringMonths, ')
          ..write('careNotes: $careNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId')
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
      light,
      humidity,
      petToxicity,
      floweringMonths,
      careNotes,
      createdAt,
      updatedAt,
      deletedAt,
      localRev,
      deviceId);
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
          other.light == this.light &&
          other.humidity == this.humidity &&
          other.petToxicity == this.petToxicity &&
          other.floweringMonths == this.floweringMonths &&
          other.careNotes == this.careNotes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.deviceId == this.deviceId);
}

class SpeciesTableCompanion extends UpdateCompanion<SpeciesTableData> {
  final Value<String> id;
  final Value<String> scientificName;
  final Value<String> popularName;
  final Value<int?> defaultIrrigationFrequencyDays;
  final Value<List<String>> recommendedSoilTypes;
  final Value<LightRequirement?> light;
  final Value<HumidityLevel?> humidity;
  final Value<PetToxicity> petToxicity;
  final Value<Set<int>> floweringMonths;
  final Value<String?> careNotes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const SpeciesTableCompanion({
    this.id = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.popularName = const Value.absent(),
    this.defaultIrrigationFrequencyDays = const Value.absent(),
    this.recommendedSoilTypes = const Value.absent(),
    this.light = const Value.absent(),
    this.humidity = const Value.absent(),
    this.petToxicity = const Value.absent(),
    this.floweringMonths = const Value.absent(),
    this.careNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeciesTableCompanion.insert({
    required String id,
    required String scientificName,
    required String popularName,
    this.defaultIrrigationFrequencyDays = const Value.absent(),
    required List<String> recommendedSoilTypes,
    this.light = const Value.absent(),
    this.humidity = const Value.absent(),
    this.petToxicity = const Value.absent(),
    this.floweringMonths = const Value.absent(),
    this.careNotes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
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
    Expression<String>? light,
    Expression<String>? humidity,
    Expression<String>? petToxicity,
    Expression<int>? floweringMonths,
    Expression<String>? careNotes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<String>? deviceId,
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
      if (light != null) 'light': light,
      if (humidity != null) 'humidity': humidity,
      if (petToxicity != null) 'pet_toxicity': petToxicity,
      if (floweringMonths != null) 'flowering_months': floweringMonths,
      if (careNotes != null) 'care_notes': careNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeciesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? scientificName,
      Value<String>? popularName,
      Value<int?>? defaultIrrigationFrequencyDays,
      Value<List<String>>? recommendedSoilTypes,
      Value<LightRequirement?>? light,
      Value<HumidityLevel?>? humidity,
      Value<PetToxicity>? petToxicity,
      Value<Set<int>>? floweringMonths,
      Value<String?>? careNotes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return SpeciesTableCompanion(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      popularName: popularName ?? this.popularName,
      defaultIrrigationFrequencyDays:
          defaultIrrigationFrequencyDays ?? this.defaultIrrigationFrequencyDays,
      recommendedSoilTypes: recommendedSoilTypes ?? this.recommendedSoilTypes,
      light: light ?? this.light,
      humidity: humidity ?? this.humidity,
      petToxicity: petToxicity ?? this.petToxicity,
      floweringMonths: floweringMonths ?? this.floweringMonths,
      careNotes: careNotes ?? this.careNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      deviceId: deviceId ?? this.deviceId,
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
    if (light.present) {
      map['light'] = Variable<String>(
          $SpeciesTableTable.$converterlight.toSql(light.value));
    }
    if (humidity.present) {
      map['humidity'] = Variable<String>(
          $SpeciesTableTable.$converterhumidity.toSql(humidity.value));
    }
    if (petToxicity.present) {
      map['pet_toxicity'] = Variable<String>(
          $SpeciesTableTable.$converterpetToxicity.toSql(petToxicity.value));
    }
    if (floweringMonths.present) {
      map['flowering_months'] = Variable<int>($SpeciesTableTable
          .$converterfloweringMonths
          .toSql(floweringMonths.value));
    }
    if (careNotes.present) {
      map['care_notes'] = Variable<String>(careNotes.value);
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
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
          ..write('light: $light, ')
          ..write('humidity: $humidity, ')
          ..write('petToxicity: $petToxicity, ')
          ..write('floweringMonths: $floweringMonths, ')
          ..write('careNotes: $careNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId, ')
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        deviceId,
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
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
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
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
  final String? deviceId;

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
      this.deviceId,
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
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
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
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
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
      deviceId: serializer.fromJson<String?>(json['deviceId']),
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
      'deviceId': serializer.toJson<String?>(deviceId),
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
          Value<String?> deviceId = const Value.absent(),
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
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
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
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
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
          ..write('deviceId: $deviceId, ')
          ..write('isSeeded: $isSeeded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, composition, imagePath, imageSource,
      createdAt, updatedAt, deletedAt, localRev, deviceId, isSeeded);
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
          other.deviceId == this.deviceId &&
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
  final Value<String?> deviceId;
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
    this.deviceId = const Value.absent(),
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
    this.deviceId = const Value.absent(),
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
    Expression<String>? deviceId,
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
      if (deviceId != null) 'device_id': deviceId,
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
      Value<String?>? deviceId,
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
      deviceId: deviceId ?? this.deviceId,
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
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
          ..write('deviceId: $deviceId, ')
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        localRev,
        deviceId
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
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
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
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
  final String? deviceId;
  const LocationsTableData(
      {required this.id,
      required this.name,
      this.description,
      this.latitude,
      this.longitude,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev,
      this.deviceId});
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
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
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
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
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
      deviceId: serializer.fromJson<String?>(json['deviceId']),
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
      'deviceId': serializer.toJson<String?>(deviceId),
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
          int? localRev,
          Value<String?> deviceId = const Value.absent()}) =>
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
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
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
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
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
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, latitude, longitude,
      createdAt, updatedAt, deletedAt, localRev, deviceId);
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
          other.localRev == this.localRev &&
          other.deviceId == this.deviceId);
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
  final Value<String?> deviceId;
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
    this.deviceId = const Value.absent(),
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
    this.deviceId = const Value.absent(),
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
    Expression<String>? deviceId,
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
      if (deviceId != null) 'device_id': deviceId,
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
      Value<String?>? deviceId,
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
      deviceId: deviceId ?? this.deviceId,
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
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
          ..write('deviceId: $deviceId, ')
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
  static const VerificationMeta _lastPesticideAppliedAtMeta =
      const VerificationMeta('lastPesticideAppliedAt');
  @override
  late final GeneratedColumn<DateTime> lastPesticideAppliedAt =
      GeneratedColumn<DateTime>('last_pesticide_applied_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pesticideReapplicationDaysMeta =
      const VerificationMeta('pesticideReapplicationDays');
  @override
  late final GeneratedColumn<int> pesticideReapplicationDays =
      GeneratedColumn<int>('pesticide_reapplication_days', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<PlantStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('active'))
          .withConverter<PlantStatus>($PlantsTableTable.$converterstatus);
  static const VerificationMeta _statusChangedAtMeta =
      const VerificationMeta('statusChangedAt');
  @override
  late final GeneratedColumn<DateTime> statusChangedAt =
      GeneratedColumn<DateTime>('status_changed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _parentPlantIdMeta =
      const VerificationMeta('parentPlantId');
  @override
  late final GeneratedColumn<String> parentPlantId = GeneratedColumn<String>(
      'parent_plant_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES plants (id) ON DELETE SET NULL'));
  static const VerificationMeta _coverPhotoIdMeta =
      const VerificationMeta('coverPhotoId');
  @override
  late final GeneratedColumn<String> coverPhotoId = GeneratedColumn<String>(
      'cover_photo_id', aliasedName, true,
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        speciesId,
        nickname,
        soilType,
        irrigationFrequencyDays,
        acquisitionDate,
        locationId,
        lastIrrigatedAt,
        lastPesticideAppliedAt,
        pesticideReapplicationDays,
        status,
        statusChangedAt,
        parentPlantId,
        coverPhotoId,
        createdAt,
        updatedAt,
        deletedAt,
        localRev,
        deviceId
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
    if (data.containsKey('last_pesticide_applied_at')) {
      context.handle(
          _lastPesticideAppliedAtMeta,
          lastPesticideAppliedAt.isAcceptableOrUnknown(
              data['last_pesticide_applied_at']!, _lastPesticideAppliedAtMeta));
    }
    if (data.containsKey('pesticide_reapplication_days')) {
      context.handle(
          _pesticideReapplicationDaysMeta,
          pesticideReapplicationDays.isAcceptableOrUnknown(
              data['pesticide_reapplication_days']!,
              _pesticideReapplicationDaysMeta));
    }
    if (data.containsKey('status_changed_at')) {
      context.handle(
          _statusChangedAtMeta,
          statusChangedAt.isAcceptableOrUnknown(
              data['status_changed_at']!, _statusChangedAtMeta));
    }
    if (data.containsKey('parent_plant_id')) {
      context.handle(
          _parentPlantIdMeta,
          parentPlantId.isAcceptableOrUnknown(
              data['parent_plant_id']!, _parentPlantIdMeta));
    }
    if (data.containsKey('cover_photo_id')) {
      context.handle(
          _coverPhotoIdMeta,
          coverPhotoId.isAcceptableOrUnknown(
              data['cover_photo_id']!, _coverPhotoIdMeta));
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
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
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      lastIrrigatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_irrigated_at']),
      lastPesticideAppliedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_pesticide_applied_at']),
      pesticideReapplicationDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}pesticide_reapplication_days']),
      status: $PlantsTableTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      statusChangedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}status_changed_at']),
      parentPlantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_plant_id']),
      coverPhotoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_photo_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $PlantsTableTable createAlias(String alias) {
    return $PlantsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<PlantStatus, String> $converterstatus =
      const PlantStatusConverter();
}

class PlantsTableData extends DataClass implements Insertable<PlantsTableData> {
  final String id;
  final String speciesId;
  final String nickname;
  final String soilType;

  /// Null means: inherit from species.defaultIrrigationFrequencyDays
  final int? irrigationFrequencyDays;
  final DateTime acquisitionDate;
  final String? locationId;
  final DateTime? lastIrrigatedAt;

  /// Derived from the most recent 'pesticide' entry — always recomputed by
  /// PlantsRepository.refreshPesticideStatus, never user-editable.
  final DateTime? lastPesticideAppliedAt;

  /// Recurrence (in days) set on the most recent 'pesticide' entry, or null
  /// if that entry didn't request a reminder.
  final int? pesticideReapplicationDays;

  /// Lifecycle status — only `active` plants get reminders and show up in
  /// the default lists; the others keep their diary as history.
  final PlantStatus status;
  final DateTime? statusChangedAt;

  /// The plant this one was propagated from (a cutting/division), if any.
  /// Plants are only soft-deleted, so a removed parent keeps its id here.
  final String? parentPlantId;

  /// Photo picked as the plant's cover: the id of an entry (its main photo)
  /// or of an entry_photos row. Ids, not paths, since each device stores a
  /// synced photo under its own path. Null, or pointing at a photo that was
  /// deleted, means the latest photo is used.
  final String? coverPhotoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final String? deviceId;
  const PlantsTableData(
      {required this.id,
      required this.speciesId,
      required this.nickname,
      required this.soilType,
      this.irrigationFrequencyDays,
      required this.acquisitionDate,
      this.locationId,
      this.lastIrrigatedAt,
      this.lastPesticideAppliedAt,
      this.pesticideReapplicationDays,
      required this.status,
      this.statusChangedAt,
      this.parentPlantId,
      this.coverPhotoId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev,
      this.deviceId});
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
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || lastIrrigatedAt != null) {
      map['last_irrigated_at'] = Variable<DateTime>(lastIrrigatedAt);
    }
    if (!nullToAbsent || lastPesticideAppliedAt != null) {
      map['last_pesticide_applied_at'] =
          Variable<DateTime>(lastPesticideAppliedAt);
    }
    if (!nullToAbsent || pesticideReapplicationDays != null) {
      map['pesticide_reapplication_days'] =
          Variable<int>(pesticideReapplicationDays);
    }
    {
      map['status'] =
          Variable<String>($PlantsTableTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || statusChangedAt != null) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt);
    }
    if (!nullToAbsent || parentPlantId != null) {
      map['parent_plant_id'] = Variable<String>(parentPlantId);
    }
    if (!nullToAbsent || coverPhotoId != null) {
      map['cover_photo_id'] = Variable<String>(coverPhotoId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
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
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      lastIrrigatedAt: lastIrrigatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastIrrigatedAt),
      lastPesticideAppliedAt: lastPesticideAppliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPesticideAppliedAt),
      pesticideReapplicationDays:
          pesticideReapplicationDays == null && nullToAbsent
              ? const Value.absent()
              : Value(pesticideReapplicationDays),
      status: Value(status),
      statusChangedAt: statusChangedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statusChangedAt),
      parentPlantId: parentPlantId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentPlantId),
      coverPhotoId: coverPhotoId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPhotoId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
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
      locationId: serializer.fromJson<String?>(json['locationId']),
      lastIrrigatedAt: serializer.fromJson<DateTime?>(json['lastIrrigatedAt']),
      lastPesticideAppliedAt:
          serializer.fromJson<DateTime?>(json['lastPesticideAppliedAt']),
      pesticideReapplicationDays:
          serializer.fromJson<int?>(json['pesticideReapplicationDays']),
      status: serializer.fromJson<PlantStatus>(json['status']),
      statusChangedAt: serializer.fromJson<DateTime?>(json['statusChangedAt']),
      parentPlantId: serializer.fromJson<String?>(json['parentPlantId']),
      coverPhotoId: serializer.fromJson<String?>(json['coverPhotoId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
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
      'locationId': serializer.toJson<String?>(locationId),
      'lastIrrigatedAt': serializer.toJson<DateTime?>(lastIrrigatedAt),
      'lastPesticideAppliedAt':
          serializer.toJson<DateTime?>(lastPesticideAppliedAt),
      'pesticideReapplicationDays':
          serializer.toJson<int?>(pesticideReapplicationDays),
      'status': serializer.toJson<PlantStatus>(status),
      'statusChangedAt': serializer.toJson<DateTime?>(statusChangedAt),
      'parentPlantId': serializer.toJson<String?>(parentPlantId),
      'coverPhotoId': serializer.toJson<String?>(coverPhotoId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  PlantsTableData copyWith(
          {String? id,
          String? speciesId,
          String? nickname,
          String? soilType,
          Value<int?> irrigationFrequencyDays = const Value.absent(),
          DateTime? acquisitionDate,
          Value<String?> locationId = const Value.absent(),
          Value<DateTime?> lastIrrigatedAt = const Value.absent(),
          Value<DateTime?> lastPesticideAppliedAt = const Value.absent(),
          Value<int?> pesticideReapplicationDays = const Value.absent(),
          PlantStatus? status,
          Value<DateTime?> statusChangedAt = const Value.absent(),
          Value<String?> parentPlantId = const Value.absent(),
          Value<String?> coverPhotoId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev,
          Value<String?> deviceId = const Value.absent()}) =>
      PlantsTableData(
        id: id ?? this.id,
        speciesId: speciesId ?? this.speciesId,
        nickname: nickname ?? this.nickname,
        soilType: soilType ?? this.soilType,
        irrigationFrequencyDays: irrigationFrequencyDays.present
            ? irrigationFrequencyDays.value
            : this.irrigationFrequencyDays,
        acquisitionDate: acquisitionDate ?? this.acquisitionDate,
        locationId: locationId.present ? locationId.value : this.locationId,
        lastIrrigatedAt: lastIrrigatedAt.present
            ? lastIrrigatedAt.value
            : this.lastIrrigatedAt,
        lastPesticideAppliedAt: lastPesticideAppliedAt.present
            ? lastPesticideAppliedAt.value
            : this.lastPesticideAppliedAt,
        pesticideReapplicationDays: pesticideReapplicationDays.present
            ? pesticideReapplicationDays.value
            : this.pesticideReapplicationDays,
        status: status ?? this.status,
        statusChangedAt: statusChangedAt.present
            ? statusChangedAt.value
            : this.statusChangedAt,
        parentPlantId:
            parentPlantId.present ? parentPlantId.value : this.parentPlantId,
        coverPhotoId:
            coverPhotoId.present ? coverPhotoId.value : this.coverPhotoId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
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
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      lastIrrigatedAt: data.lastIrrigatedAt.present
          ? data.lastIrrigatedAt.value
          : this.lastIrrigatedAt,
      lastPesticideAppliedAt: data.lastPesticideAppliedAt.present
          ? data.lastPesticideAppliedAt.value
          : this.lastPesticideAppliedAt,
      pesticideReapplicationDays: data.pesticideReapplicationDays.present
          ? data.pesticideReapplicationDays.value
          : this.pesticideReapplicationDays,
      status: data.status.present ? data.status.value : this.status,
      statusChangedAt: data.statusChangedAt.present
          ? data.statusChangedAt.value
          : this.statusChangedAt,
      parentPlantId: data.parentPlantId.present
          ? data.parentPlantId.value
          : this.parentPlantId,
      coverPhotoId: data.coverPhotoId.present
          ? data.coverPhotoId.value
          : this.coverPhotoId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
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
          ..write('locationId: $locationId, ')
          ..write('lastIrrigatedAt: $lastIrrigatedAt, ')
          ..write('lastPesticideAppliedAt: $lastPesticideAppliedAt, ')
          ..write('pesticideReapplicationDays: $pesticideReapplicationDays, ')
          ..write('status: $status, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('parentPlantId: $parentPlantId, ')
          ..write('coverPhotoId: $coverPhotoId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId')
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
      locationId,
      lastIrrigatedAt,
      lastPesticideAppliedAt,
      pesticideReapplicationDays,
      status,
      statusChangedAt,
      parentPlantId,
      coverPhotoId,
      createdAt,
      updatedAt,
      deletedAt,
      localRev,
      deviceId);
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
          other.locationId == this.locationId &&
          other.lastIrrigatedAt == this.lastIrrigatedAt &&
          other.lastPesticideAppliedAt == this.lastPesticideAppliedAt &&
          other.pesticideReapplicationDays == this.pesticideReapplicationDays &&
          other.status == this.status &&
          other.statusChangedAt == this.statusChangedAt &&
          other.parentPlantId == this.parentPlantId &&
          other.coverPhotoId == this.coverPhotoId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.deviceId == this.deviceId);
}

class PlantsTableCompanion extends UpdateCompanion<PlantsTableData> {
  final Value<String> id;
  final Value<String> speciesId;
  final Value<String> nickname;
  final Value<String> soilType;
  final Value<int?> irrigationFrequencyDays;
  final Value<DateTime> acquisitionDate;
  final Value<String?> locationId;
  final Value<DateTime?> lastIrrigatedAt;
  final Value<DateTime?> lastPesticideAppliedAt;
  final Value<int?> pesticideReapplicationDays;
  final Value<PlantStatus> status;
  final Value<DateTime?> statusChangedAt;
  final Value<String?> parentPlantId;
  final Value<String?> coverPhotoId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const PlantsTableCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.soilType = const Value.absent(),
    this.irrigationFrequencyDays = const Value.absent(),
    this.acquisitionDate = const Value.absent(),
    this.locationId = const Value.absent(),
    this.lastIrrigatedAt = const Value.absent(),
    this.lastPesticideAppliedAt = const Value.absent(),
    this.pesticideReapplicationDays = const Value.absent(),
    this.status = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.parentPlantId = const Value.absent(),
    this.coverPhotoId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantsTableCompanion.insert({
    required String id,
    required String speciesId,
    required String nickname,
    required String soilType,
    this.irrigationFrequencyDays = const Value.absent(),
    required DateTime acquisitionDate,
    this.locationId = const Value.absent(),
    this.lastIrrigatedAt = const Value.absent(),
    this.lastPesticideAppliedAt = const Value.absent(),
    this.pesticideReapplicationDays = const Value.absent(),
    this.status = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.parentPlantId = const Value.absent(),
    this.coverPhotoId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
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
    Expression<String>? locationId,
    Expression<DateTime>? lastIrrigatedAt,
    Expression<DateTime>? lastPesticideAppliedAt,
    Expression<int>? pesticideReapplicationDays,
    Expression<String>? status,
    Expression<DateTime>? statusChangedAt,
    Expression<String>? parentPlantId,
    Expression<String>? coverPhotoId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<String>? deviceId,
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
      if (locationId != null) 'location_id': locationId,
      if (lastIrrigatedAt != null) 'last_irrigated_at': lastIrrigatedAt,
      if (lastPesticideAppliedAt != null)
        'last_pesticide_applied_at': lastPesticideAppliedAt,
      if (pesticideReapplicationDays != null)
        'pesticide_reapplication_days': pesticideReapplicationDays,
      if (status != null) 'status': status,
      if (statusChangedAt != null) 'status_changed_at': statusChangedAt,
      if (parentPlantId != null) 'parent_plant_id': parentPlantId,
      if (coverPhotoId != null) 'cover_photo_id': coverPhotoId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (deviceId != null) 'device_id': deviceId,
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
      Value<String?>? locationId,
      Value<DateTime?>? lastIrrigatedAt,
      Value<DateTime?>? lastPesticideAppliedAt,
      Value<int?>? pesticideReapplicationDays,
      Value<PlantStatus>? status,
      Value<DateTime?>? statusChangedAt,
      Value<String?>? parentPlantId,
      Value<String?>? coverPhotoId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return PlantsTableCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      nickname: nickname ?? this.nickname,
      soilType: soilType ?? this.soilType,
      irrigationFrequencyDays:
          irrigationFrequencyDays ?? this.irrigationFrequencyDays,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      locationId: locationId ?? this.locationId,
      lastIrrigatedAt: lastIrrigatedAt ?? this.lastIrrigatedAt,
      lastPesticideAppliedAt:
          lastPesticideAppliedAt ?? this.lastPesticideAppliedAt,
      pesticideReapplicationDays:
          pesticideReapplicationDays ?? this.pesticideReapplicationDays,
      status: status ?? this.status,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      parentPlantId: parentPlantId ?? this.parentPlantId,
      coverPhotoId: coverPhotoId ?? this.coverPhotoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      deviceId: deviceId ?? this.deviceId,
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
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (lastIrrigatedAt.present) {
      map['last_irrigated_at'] = Variable<DateTime>(lastIrrigatedAt.value);
    }
    if (lastPesticideAppliedAt.present) {
      map['last_pesticide_applied_at'] =
          Variable<DateTime>(lastPesticideAppliedAt.value);
    }
    if (pesticideReapplicationDays.present) {
      map['pesticide_reapplication_days'] =
          Variable<int>(pesticideReapplicationDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $PlantsTableTable.$converterstatus.toSql(status.value));
    }
    if (statusChangedAt.present) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt.value);
    }
    if (parentPlantId.present) {
      map['parent_plant_id'] = Variable<String>(parentPlantId.value);
    }
    if (coverPhotoId.present) {
      map['cover_photo_id'] = Variable<String>(coverPhotoId.value);
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
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
          ..write('locationId: $locationId, ')
          ..write('lastIrrigatedAt: $lastIrrigatedAt, ')
          ..write('lastPesticideAppliedAt: $lastPesticideAppliedAt, ')
          ..write('pesticideReapplicationDays: $pesticideReapplicationDays, ')
          ..write('status: $status, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('parentPlantId: $parentPlantId, ')
          ..write('coverPhotoId: $coverPhotoId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId, ')
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        localRev,
        deviceId
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
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
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
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
  final String? deviceId;
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
      required this.localRev,
      this.deviceId});
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
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
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
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
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
      deviceId: serializer.fromJson<String?>(json['deviceId']),
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
      'deviceId': serializer.toJson<String?>(deviceId),
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
          int? localRev,
          Value<String?> deviceId = const Value.absent()}) =>
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
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
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
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
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
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      localRev,
      deviceId);
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
          other.localRev == this.localRev &&
          other.deviceId == this.deviceId);
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
  final Value<String?> deviceId;
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
    this.deviceId = const Value.absent(),
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
    this.deviceId = const Value.absent(),
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
    Expression<String>? deviceId,
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
      if (deviceId != null) 'device_id': deviceId,
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
      Value<String?>? deviceId,
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
      deviceId: deviceId ?? this.deviceId,
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
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
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryPhotosTableTable extends EntryPhotosTable
    with TableInfo<$EntryPhotosTableTable, EntryPhotosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryPhotosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryIdMeta =
      const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
      'entry_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES entries (id) ON DELETE CASCADE'));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entryId,
        photoPath,
        position,
        createdAt,
        updatedAt,
        deletedAt,
        localRev,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_photos';
  @override
  VerificationContext validateIntegrity(
      Insertable<EntryPhotosTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta,
          entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    } else if (isInserting) {
      context.missing(_photoPathMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryPhotosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryPhotosTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $EntryPhotosTableTable createAlias(String alias) {
    return $EntryPhotosTableTable(attachedDatabase, alias);
  }
}

class EntryPhotosTableData extends DataClass
    implements Insertable<EntryPhotosTableData> {
  final String id;
  final String entryId;
  final String photoPath;

  /// Order within the entry; the entry's own photo comes before all of them.
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final String? deviceId;
  const EntryPhotosTableData(
      {required this.id,
      required this.entryId,
      required this.photoPath,
      required this.position,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['photo_path'] = Variable<String>(photoPath);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  EntryPhotosTableCompanion toCompanion(bool nullToAbsent) {
    return EntryPhotosTableCompanion(
      id: Value(id),
      entryId: Value(entryId),
      photoPath: Value(photoPath),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory EntryPhotosTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryPhotosTableData(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      photoPath: serializer.fromJson<String>(json['photoPath']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'photoPath': serializer.toJson<String>(photoPath),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  EntryPhotosTableData copyWith(
          {String? id,
          String? entryId,
          String? photoPath,
          int? position,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev,
          Value<String?> deviceId = const Value.absent()}) =>
      EntryPhotosTableData(
        id: id ?? this.id,
        entryId: entryId ?? this.entryId,
        photoPath: photoPath ?? this.photoPath,
        position: position ?? this.position,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  EntryPhotosTableData copyWithCompanion(EntryPhotosTableCompanion data) {
    return EntryPhotosTableData(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryPhotosTableData(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('photoPath: $photoPath, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entryId, photoPath, position, createdAt,
      updatedAt, deletedAt, localRev, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryPhotosTableData &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.photoPath == this.photoPath &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.deviceId == this.deviceId);
}

class EntryPhotosTableCompanion extends UpdateCompanion<EntryPhotosTableData> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<String> photoPath;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const EntryPhotosTableCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryPhotosTableCompanion.insert({
    required String id,
    required String entryId,
    required String photoPath,
    this.position = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryId = Value(entryId),
        photoPath = Value(photoPath),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<EntryPhotosTableData> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<String>? photoPath,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (photoPath != null) 'photo_path': photoPath,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryPhotosTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryId,
      Value<String>? photoPath,
      Value<int>? position,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return EntryPhotosTableCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      photoPath: photoPath ?? this.photoPath,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryPhotosTableCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('photoPath: $photoPath, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DefensivosTableTable extends DefensivosTable
    with TableInfo<$DefensivosTableTable, DefensivosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefensivosTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customCategoryLabelMeta =
      const VerificationMeta('customCategoryLabel');
  @override
  late final GeneratedColumn<String> customCategoryLabel =
      GeneratedColumn<String>('custom_category_label', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _compositionMeta =
      const VerificationMeta('composition');
  @override
  late final GeneratedColumn<String> composition = GeneratedColumn<String>(
      'composition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _carenciaDaysMeta =
      const VerificationMeta('carenciaDays');
  @override
  late final GeneratedColumn<int> carenciaDays = GeneratedColumn<int>(
      'carencia_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        customCategoryLabel,
        composition,
        carenciaDays,
        imagePath,
        imageSource,
        createdAt,
        updatedAt,
        deletedAt,
        localRev,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'defensivos';
  @override
  VerificationContext validateIntegrity(
      Insertable<DefensivosTableData> instance,
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
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('custom_category_label')) {
      context.handle(
          _customCategoryLabelMeta,
          customCategoryLabel.isAcceptableOrUnknown(
              data['custom_category_label']!, _customCategoryLabelMeta));
    }
    if (data.containsKey('composition')) {
      context.handle(
          _compositionMeta,
          composition.isAcceptableOrUnknown(
              data['composition']!, _compositionMeta));
    }
    if (data.containsKey('carencia_days')) {
      context.handle(
          _carenciaDaysMeta,
          carenciaDays.isAcceptableOrUnknown(
              data['carencia_days']!, _carenciaDaysMeta));
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DefensivosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DefensivosTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      customCategoryLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}custom_category_label']),
      composition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}composition']),
      carenciaDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}carencia_days']),
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
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $DefensivosTableTable createAlias(String alias) {
    return $DefensivosTableTable(attachedDatabase, alias);
  }
}

class DefensivosTableData extends DataClass
    implements Insertable<DefensivosTableData> {
  final String id;
  final String name;

  /// Stores a [DefensivoCategory] name, or null.
  final String? category;

  /// Only meaningful when [category] is [DefensivoCategory.custom] — the
  /// free-text label the user typed for their own category.
  final String? customCategoryLabel;

  /// Composition + application instructions.
  final String? composition;
  final int? carenciaDays;
  final String? imagePath;
  final String? imageSource;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final String? deviceId;
  const DefensivosTableData(
      {required this.id,
      required this.name,
      this.category,
      this.customCategoryLabel,
      this.composition,
      this.carenciaDays,
      this.imagePath,
      this.imageSource,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || customCategoryLabel != null) {
      map['custom_category_label'] = Variable<String>(customCategoryLabel);
    }
    if (!nullToAbsent || composition != null) {
      map['composition'] = Variable<String>(composition);
    }
    if (!nullToAbsent || carenciaDays != null) {
      map['carencia_days'] = Variable<int>(carenciaDays);
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
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  DefensivosTableCompanion toCompanion(bool nullToAbsent) {
    return DefensivosTableCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      customCategoryLabel: customCategoryLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(customCategoryLabel),
      composition: composition == null && nullToAbsent
          ? const Value.absent()
          : Value(composition),
      carenciaDays: carenciaDays == null && nullToAbsent
          ? const Value.absent()
          : Value(carenciaDays),
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
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory DefensivosTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DefensivosTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      customCategoryLabel:
          serializer.fromJson<String?>(json['customCategoryLabel']),
      composition: serializer.fromJson<String?>(json['composition']),
      carenciaDays: serializer.fromJson<int?>(json['carenciaDays']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      imageSource: serializer.fromJson<String?>(json['imageSource']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'customCategoryLabel': serializer.toJson<String?>(customCategoryLabel),
      'composition': serializer.toJson<String?>(composition),
      'carenciaDays': serializer.toJson<int?>(carenciaDays),
      'imagePath': serializer.toJson<String?>(imagePath),
      'imageSource': serializer.toJson<String?>(imageSource),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  DefensivosTableData copyWith(
          {String? id,
          String? name,
          Value<String?> category = const Value.absent(),
          Value<String?> customCategoryLabel = const Value.absent(),
          Value<String?> composition = const Value.absent(),
          Value<int?> carenciaDays = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<String?> imageSource = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev,
          Value<String?> deviceId = const Value.absent()}) =>
      DefensivosTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category.present ? category.value : this.category,
        customCategoryLabel: customCategoryLabel.present
            ? customCategoryLabel.value
            : this.customCategoryLabel,
        composition: composition.present ? composition.value : this.composition,
        carenciaDays:
            carenciaDays.present ? carenciaDays.value : this.carenciaDays,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        imageSource: imageSource.present ? imageSource.value : this.imageSource,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  DefensivosTableData copyWithCompanion(DefensivosTableCompanion data) {
    return DefensivosTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      customCategoryLabel: data.customCategoryLabel.present
          ? data.customCategoryLabel.value
          : this.customCategoryLabel,
      composition:
          data.composition.present ? data.composition.value : this.composition,
      carenciaDays: data.carenciaDays.present
          ? data.carenciaDays.value
          : this.carenciaDays,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      imageSource:
          data.imageSource.present ? data.imageSource.value : this.imageSource,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DefensivosTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('customCategoryLabel: $customCategoryLabel, ')
          ..write('composition: $composition, ')
          ..write('carenciaDays: $carenciaDays, ')
          ..write('imagePath: $imagePath, ')
          ..write('imageSource: $imageSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      customCategoryLabel,
      composition,
      carenciaDays,
      imagePath,
      imageSource,
      createdAt,
      updatedAt,
      deletedAt,
      localRev,
      deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DefensivosTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.customCategoryLabel == this.customCategoryLabel &&
          other.composition == this.composition &&
          other.carenciaDays == this.carenciaDays &&
          other.imagePath == this.imagePath &&
          other.imageSource == this.imageSource &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.deviceId == this.deviceId);
}

class DefensivosTableCompanion extends UpdateCompanion<DefensivosTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> customCategoryLabel;
  final Value<String?> composition;
  final Value<int?> carenciaDays;
  final Value<String?> imagePath;
  final Value<String?> imageSource;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const DefensivosTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.customCategoryLabel = const Value.absent(),
    this.composition = const Value.absent(),
    this.carenciaDays = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.imageSource = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DefensivosTableCompanion.insert({
    required String id,
    required String name,
    this.category = const Value.absent(),
    this.customCategoryLabel = const Value.absent(),
    this.composition = const Value.absent(),
    this.carenciaDays = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.imageSource = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DefensivosTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? customCategoryLabel,
    Expression<String>? composition,
    Expression<int>? carenciaDays,
    Expression<String>? imagePath,
    Expression<String>? imageSource,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (customCategoryLabel != null)
        'custom_category_label': customCategoryLabel,
      if (composition != null) 'composition': composition,
      if (carenciaDays != null) 'carencia_days': carenciaDays,
      if (imagePath != null) 'image_path': imagePath,
      if (imageSource != null) 'image_source': imageSource,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DefensivosTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? category,
      Value<String?>? customCategoryLabel,
      Value<String?>? composition,
      Value<int?>? carenciaDays,
      Value<String?>? imagePath,
      Value<String?>? imageSource,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return DefensivosTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      customCategoryLabel: customCategoryLabel ?? this.customCategoryLabel,
      composition: composition ?? this.composition,
      carenciaDays: carenciaDays ?? this.carenciaDays,
      imagePath: imagePath ?? this.imagePath,
      imageSource: imageSource ?? this.imageSource,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      deviceId: deviceId ?? this.deviceId,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (customCategoryLabel.present) {
      map['custom_category_label'] =
          Variable<String>(customCategoryLabel.value);
    }
    if (composition.present) {
      map['composition'] = Variable<String>(composition.value);
    }
    if (carenciaDays.present) {
      map['carencia_days'] = Variable<int>(carenciaDays.value);
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefensivosTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('customCategoryLabel: $customCategoryLabel, ')
          ..write('composition: $composition, ')
          ..write('carenciaDays: $carenciaDays, ')
          ..write('imagePath: $imagePath, ')
          ..write('imageSource: $imageSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTableTable extends RemindersTable
    with TableInfo<$RemindersTableTable, RemindersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTableTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<EntryType, String> entryType =
      GeneratedColumn<String>('entry_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<EntryType>($RemindersTableTable.$converterentryType);
  static const VerificationMeta _intervalDaysMeta =
      const VerificationMeta('intervalDays');
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
      'interval_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
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
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        plantId,
        entryType,
        intervalDays,
        enabled,
        createdAt,
        updatedAt,
        deletedAt,
        localRev,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<RemindersTableData> instance,
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
    if (data.containsKey('interval_days')) {
      context.handle(
          _intervalDaysMeta,
          intervalDays.isAcceptableOrUnknown(
              data['interval_days']!, _intervalDaysMeta));
    } else if (isInserting) {
      context.missing(_intervalDaysMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
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
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemindersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemindersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      plantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plant_id'])!,
      entryType: $RemindersTableTable.$converterentryType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}entry_type'])!),
      intervalDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_days'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      localRev: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_rev'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $RemindersTableTable createAlias(String alias) {
    return $RemindersTableTable(attachedDatabase, alias);
  }

  static TypeConverter<EntryType, String> $converterentryType =
      const EntryTypeConverter();
}

class RemindersTableData extends DataClass
    implements Insertable<RemindersTableData> {
  final String id;
  final String plantId;
  final EntryType entryType;
  final int intervalDays;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final String? deviceId;
  const RemindersTableData(
      {required this.id,
      required this.plantId,
      required this.entryType,
      required this.intervalDays,
      required this.enabled,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.localRev,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    {
      map['entry_type'] = Variable<String>(
          $RemindersTableTable.$converterentryType.toSql(entryType));
    }
    map['interval_days'] = Variable<int>(intervalDays);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  RemindersTableCompanion toCompanion(bool nullToAbsent) {
    return RemindersTableCompanion(
      id: Value(id),
      plantId: Value(plantId),
      entryType: Value(entryType),
      intervalDays: Value(intervalDays),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory RemindersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemindersTableData(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plantId']),
      entryType: serializer.fromJson<EntryType>(json['entryType']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plantId': serializer.toJson<String>(plantId),
      'entryType': serializer.toJson<EntryType>(entryType),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  RemindersTableData copyWith(
          {String? id,
          String? plantId,
          EntryType? entryType,
          int? intervalDays,
          bool? enabled,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? localRev,
          Value<String?> deviceId = const Value.absent()}) =>
      RemindersTableData(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        entryType: entryType ?? this.entryType,
        intervalDays: intervalDays ?? this.intervalDays,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        localRev: localRev ?? this.localRev,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  RemindersTableData copyWithCompanion(RemindersTableCompanion data) {
    return RemindersTableData(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemindersTableData(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('entryType: $entryType, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, entryType, intervalDays, enabled,
      createdAt, updatedAt, deletedAt, localRev, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemindersTableData &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.entryType == this.entryType &&
          other.intervalDays == this.intervalDays &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.deviceId == this.deviceId);
}

class RemindersTableCompanion extends UpdateCompanion<RemindersTableData> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<EntryType> entryType;
  final Value<int> intervalDays;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const RemindersTableCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersTableCompanion.insert({
    required String id,
    required String plantId,
    required EntryType entryType,
    required int intervalDays,
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        plantId = Value(plantId),
        entryType = Value(entryType),
        intervalDays = Value(intervalDays),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RemindersTableData> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? entryType,
    Expression<int>? intervalDays,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (entryType != null) 'entry_type': entryType,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? plantId,
      Value<EntryType>? entryType,
      Value<int>? intervalDays,
      Value<bool>? enabled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? localRev,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return RemindersTableCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      entryType: entryType ?? this.entryType,
      intervalDays: intervalDays ?? this.intervalDays,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      deviceId: deviceId ?? this.deviceId,
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
    if (entryType.present) {
      map['entry_type'] = Variable<String>(
          $RemindersTableTable.$converterentryType.toSql(entryType.value));
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersTableCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('entryType: $entryType, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('deviceId: $deviceId, ')
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

class $SyncEntryTypesTableTable extends SyncEntryTypesTable
    with TableInfo<$SyncEntryTypesTableTable, SyncEntryTypesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEntryTypesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [peerId, entryType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_entry_types';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncEntryTypesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerId, entryType};
  @override
  SyncEntryTypesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEntryTypesTableData(
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
    );
  }

  @override
  $SyncEntryTypesTableTable createAlias(String alias) {
    return $SyncEntryTypesTableTable(attachedDatabase, alias);
  }
}

class SyncEntryTypesTableData extends DataClass
    implements Insertable<SyncEntryTypesTableData> {
  final String peerId;
  final String entryType;
  const SyncEntryTypesTableData(
      {required this.peerId, required this.entryType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_id'] = Variable<String>(peerId);
    map['entry_type'] = Variable<String>(entryType);
    return map;
  }

  SyncEntryTypesTableCompanion toCompanion(bool nullToAbsent) {
    return SyncEntryTypesTableCompanion(
      peerId: Value(peerId),
      entryType: Value(entryType),
    );
  }

  factory SyncEntryTypesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEntryTypesTableData(
      peerId: serializer.fromJson<String>(json['peerId']),
      entryType: serializer.fromJson<String>(json['entryType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerId': serializer.toJson<String>(peerId),
      'entryType': serializer.toJson<String>(entryType),
    };
  }

  SyncEntryTypesTableData copyWith({String? peerId, String? entryType}) =>
      SyncEntryTypesTableData(
        peerId: peerId ?? this.peerId,
        entryType: entryType ?? this.entryType,
      );
  SyncEntryTypesTableData copyWithCompanion(SyncEntryTypesTableCompanion data) {
    return SyncEntryTypesTableData(
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntryTypesTableData(')
          ..write('peerId: $peerId, ')
          ..write('entryType: $entryType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(peerId, entryType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEntryTypesTableData &&
          other.peerId == this.peerId &&
          other.entryType == this.entryType);
}

class SyncEntryTypesTableCompanion
    extends UpdateCompanion<SyncEntryTypesTableData> {
  final Value<String> peerId;
  final Value<String> entryType;
  final Value<int> rowid;
  const SyncEntryTypesTableCompanion({
    this.peerId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEntryTypesTableCompanion.insert({
    required String peerId,
    required String entryType,
    this.rowid = const Value.absent(),
  })  : peerId = Value(peerId),
        entryType = Value(entryType);
  static Insertable<SyncEntryTypesTableData> custom({
    Expression<String>? peerId,
    Expression<String>? entryType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerId != null) 'peer_id': peerId,
      if (entryType != null) 'entry_type': entryType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEntryTypesTableCompanion copyWith(
      {Value<String>? peerId, Value<String>? entryType, Value<int>? rowid}) {
    return SyncEntryTypesTableCompanion(
      peerId: peerId ?? this.peerId,
      entryType: entryType ?? this.entryType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntryTypesTableCompanion(')
          ..write('peerId: $peerId, ')
          ..write('entryType: $entryType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncEntityTypesTableTable extends SyncEntityTypesTable
    with TableInfo<$SyncEntityTypesTableTable, SyncEntityTypesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEntityTypesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [peerId, entityType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_entity_types';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncEntityTypesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerId, entityType};
  @override
  SyncEntityTypesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEntityTypesTableData(
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
    );
  }

  @override
  $SyncEntityTypesTableTable createAlias(String alias) {
    return $SyncEntityTypesTableTable(attachedDatabase, alias);
  }
}

class SyncEntityTypesTableData extends DataClass
    implements Insertable<SyncEntityTypesTableData> {
  final String peerId;
  final String entityType;
  const SyncEntityTypesTableData(
      {required this.peerId, required this.entityType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_id'] = Variable<String>(peerId);
    map['entity_type'] = Variable<String>(entityType);
    return map;
  }

  SyncEntityTypesTableCompanion toCompanion(bool nullToAbsent) {
    return SyncEntityTypesTableCompanion(
      peerId: Value(peerId),
      entityType: Value(entityType),
    );
  }

  factory SyncEntityTypesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEntityTypesTableData(
      peerId: serializer.fromJson<String>(json['peerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerId': serializer.toJson<String>(peerId),
      'entityType': serializer.toJson<String>(entityType),
    };
  }

  SyncEntityTypesTableData copyWith({String? peerId, String? entityType}) =>
      SyncEntityTypesTableData(
        peerId: peerId ?? this.peerId,
        entityType: entityType ?? this.entityType,
      );
  SyncEntityTypesTableData copyWithCompanion(
      SyncEntityTypesTableCompanion data) {
    return SyncEntityTypesTableData(
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityTypesTableData(')
          ..write('peerId: $peerId, ')
          ..write('entityType: $entityType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(peerId, entityType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEntityTypesTableData &&
          other.peerId == this.peerId &&
          other.entityType == this.entityType);
}

class SyncEntityTypesTableCompanion
    extends UpdateCompanion<SyncEntityTypesTableData> {
  final Value<String> peerId;
  final Value<String> entityType;
  final Value<int> rowid;
  const SyncEntityTypesTableCompanion({
    this.peerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEntityTypesTableCompanion.insert({
    required String peerId,
    required String entityType,
    this.rowid = const Value.absent(),
  })  : peerId = Value(peerId),
        entityType = Value(entityType);
  static Insertable<SyncEntityTypesTableData> custom({
    Expression<String>? peerId,
    Expression<String>? entityType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerId != null) 'peer_id': peerId,
      if (entityType != null) 'entity_type': entityType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEntityTypesTableCompanion copyWith(
      {Value<String>? peerId, Value<String>? entityType, Value<int>? rowid}) {
    return SyncEntityTypesTableCompanion(
      peerId: peerId ?? this.peerId,
      entityType: entityType ?? this.entityType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityTypesTableCompanion(')
          ..write('peerId: $peerId, ')
          ..write('entityType: $entityType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConfirmedEntityTypesTableTable extends SyncConfirmedEntityTypesTable
    with
        TableInfo<$SyncConfirmedEntityTypesTableTable,
            SyncConfirmedEntityTypesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConfirmedEntityTypesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [peerId, entityType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_confirmed_entity_types';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncConfirmedEntityTypesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerId, entityType};
  @override
  SyncConfirmedEntityTypesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConfirmedEntityTypesTableData(
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
    );
  }

  @override
  $SyncConfirmedEntityTypesTableTable createAlias(String alias) {
    return $SyncConfirmedEntityTypesTableTable(attachedDatabase, alias);
  }
}

class SyncConfirmedEntityTypesTableData extends DataClass
    implements Insertable<SyncConfirmedEntityTypesTableData> {
  final String peerId;
  final String entityType;
  const SyncConfirmedEntityTypesTableData(
      {required this.peerId, required this.entityType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_id'] = Variable<String>(peerId);
    map['entity_type'] = Variable<String>(entityType);
    return map;
  }

  SyncConfirmedEntityTypesTableCompanion toCompanion(bool nullToAbsent) {
    return SyncConfirmedEntityTypesTableCompanion(
      peerId: Value(peerId),
      entityType: Value(entityType),
    );
  }

  factory SyncConfirmedEntityTypesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConfirmedEntityTypesTableData(
      peerId: serializer.fromJson<String>(json['peerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerId': serializer.toJson<String>(peerId),
      'entityType': serializer.toJson<String>(entityType),
    };
  }

  SyncConfirmedEntityTypesTableData copyWith(
          {String? peerId, String? entityType}) =>
      SyncConfirmedEntityTypesTableData(
        peerId: peerId ?? this.peerId,
        entityType: entityType ?? this.entityType,
      );
  SyncConfirmedEntityTypesTableData copyWithCompanion(
      SyncConfirmedEntityTypesTableCompanion data) {
    return SyncConfirmedEntityTypesTableData(
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConfirmedEntityTypesTableData(')
          ..write('peerId: $peerId, ')
          ..write('entityType: $entityType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(peerId, entityType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConfirmedEntityTypesTableData &&
          other.peerId == this.peerId &&
          other.entityType == this.entityType);
}

class SyncConfirmedEntityTypesTableCompanion
    extends UpdateCompanion<SyncConfirmedEntityTypesTableData> {
  final Value<String> peerId;
  final Value<String> entityType;
  final Value<int> rowid;
  const SyncConfirmedEntityTypesTableCompanion({
    this.peerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConfirmedEntityTypesTableCompanion.insert({
    required String peerId,
    required String entityType,
    this.rowid = const Value.absent(),
  })  : peerId = Value(peerId),
        entityType = Value(entityType);
  static Insertable<SyncConfirmedEntityTypesTableData> custom({
    Expression<String>? peerId,
    Expression<String>? entityType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerId != null) 'peer_id': peerId,
      if (entityType != null) 'entity_type': entityType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConfirmedEntityTypesTableCompanion copyWith(
      {Value<String>? peerId, Value<String>? entityType, Value<int>? rowid}) {
    return SyncConfirmedEntityTypesTableCompanion(
      peerId: peerId ?? this.peerId,
      entityType: entityType ?? this.entityType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConfirmedEntityTypesTableCompanion(')
          ..write('peerId: $peerId, ')
          ..write('entityType: $entityType, ')
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
  late final $EntryPhotosTableTable entryPhotosTable =
      $EntryPhotosTableTable(this);
  late final $DefensivosTableTable defensivosTable =
      $DefensivosTableTable(this);
  late final $RemindersTableTable remindersTable = $RemindersTableTable(this);
  late final $SyncMetaTableTable syncMetaTable = $SyncMetaTableTable(this);
  late final $SyncCursorsTableTable syncCursorsTable =
      $SyncCursorsTableTable(this);
  late final $SyncEntryTypesTableTable syncEntryTypesTable =
      $SyncEntryTypesTableTable(this);
  late final $SyncEntityTypesTableTable syncEntityTypesTable =
      $SyncEntityTypesTableTable(this);
  late final $SyncConfirmedEntityTypesTableTable syncConfirmedEntityTypesTable =
      $SyncConfirmedEntityTypesTableTable(this);
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
        entryPhotosTable,
        defensivosTable,
        remindersTable,
        syncMetaTable,
        syncCursorsTable,
        syncEntryTypesTable,
        syncEntityTypesTable,
        syncConfirmedEntityTypesTable
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
          WritePropagation(
            on: TableUpdateQuery.onTableName('entries',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('entry_photos', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('plants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reminders', kind: UpdateKind.delete),
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
  Value<LightRequirement?> light,
  Value<HumidityLevel?> humidity,
  Value<PetToxicity> petToxicity,
  Value<Set<int>> floweringMonths,
  Value<String?> careNotes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$SpeciesTableTableUpdateCompanionBuilder = SpeciesTableCompanion
    Function({
  Value<String> id,
  Value<String> scientificName,
  Value<String> popularName,
  Value<int?> defaultIrrigationFrequencyDays,
  Value<List<String>> recommendedSoilTypes,
  Value<LightRequirement?> light,
  Value<HumidityLevel?> humidity,
  Value<PetToxicity> petToxicity,
  Value<Set<int>> floweringMonths,
  Value<String?> careNotes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
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

  ColumnWithTypeConverterFilters<LightRequirement?, LightRequirement, String>
      get light => $composableBuilder(
          column: $table.light,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<HumidityLevel?, HumidityLevel, String>
      get humidity => $composableBuilder(
          column: $table.humidity,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PetToxicity, PetToxicity, String>
      get petToxicity => $composableBuilder(
          column: $table.petToxicity,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Set<int>, Set<int>, int> get floweringMonths =>
      $composableBuilder(
          column: $table.floweringMonths,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get careNotes => $composableBuilder(
      column: $table.careNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get light => $composableBuilder(
      column: $table.light, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get humidity => $composableBuilder(
      column: $table.humidity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get petToxicity => $composableBuilder(
      column: $table.petToxicity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get floweringMonths => $composableBuilder(
      column: $table.floweringMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get careNotes => $composableBuilder(
      column: $table.careNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumnWithTypeConverter<LightRequirement?, String> get light =>
      $composableBuilder(column: $table.light, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HumidityLevel?, String> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PetToxicity, String> get petToxicity =>
      $composableBuilder(
          column: $table.petToxicity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<int>, int> get floweringMonths =>
      $composableBuilder(
          column: $table.floweringMonths, builder: (column) => column);

  GeneratedColumn<String> get careNotes =>
      $composableBuilder(column: $table.careNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

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
            Value<LightRequirement?> light = const Value.absent(),
            Value<HumidityLevel?> humidity = const Value.absent(),
            Value<PetToxicity> petToxicity = const Value.absent(),
            Value<Set<int>> floweringMonths = const Value.absent(),
            Value<String?> careNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpeciesTableCompanion(
            id: id,
            scientificName: scientificName,
            popularName: popularName,
            defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays,
            recommendedSoilTypes: recommendedSoilTypes,
            light: light,
            humidity: humidity,
            petToxicity: petToxicity,
            floweringMonths: floweringMonths,
            careNotes: careNotes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String scientificName,
            required String popularName,
            Value<int?> defaultIrrigationFrequencyDays = const Value.absent(),
            required List<String> recommendedSoilTypes,
            Value<LightRequirement?> light = const Value.absent(),
            Value<HumidityLevel?> humidity = const Value.absent(),
            Value<PetToxicity> petToxicity = const Value.absent(),
            Value<Set<int>> floweringMonths = const Value.absent(),
            Value<String?> careNotes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpeciesTableCompanion.insert(
            id: id,
            scientificName: scientificName,
            popularName: popularName,
            defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays,
            recommendedSoilTypes: recommendedSoilTypes,
            light: light,
            humidity: humidity,
            petToxicity: petToxicity,
            floweringMonths: floweringMonths,
            careNotes: careNotes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
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
  Value<String?> deviceId,
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
  Value<String?> deviceId,
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

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

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
            Value<String?> deviceId = const Value.absent(),
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
            deviceId: deviceId,
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
            Value<String?> deviceId = const Value.absent(),
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
            deviceId: deviceId,
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
  Value<String?> deviceId,
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
  Value<String?> deviceId,
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

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

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
            Value<String?> deviceId = const Value.absent(),
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
            deviceId: deviceId,
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
            Value<String?> deviceId = const Value.absent(),
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
            deviceId: deviceId,
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
  Value<String?> locationId,
  Value<DateTime?> lastIrrigatedAt,
  Value<DateTime?> lastPesticideAppliedAt,
  Value<int?> pesticideReapplicationDays,
  Value<PlantStatus> status,
  Value<DateTime?> statusChangedAt,
  Value<String?> parentPlantId,
  Value<String?> coverPhotoId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
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
  Value<String?> locationId,
  Value<DateTime?> lastIrrigatedAt,
  Value<DateTime?> lastPesticideAppliedAt,
  Value<int?> pesticideReapplicationDays,
  Value<PlantStatus> status,
  Value<DateTime?> statusChangedAt,
  Value<String?> parentPlantId,
  Value<String?> coverPhotoId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
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

  static $PlantsTableTable _parentPlantIdTable(_$AppDatabase db) =>
      db.plantsTable.createAlias('plants__parent_plant_id__plants__id');

  $$PlantsTableTableProcessedTableManager? get parentPlantId {
    final $_column = $_itemColumn<String>('parent_plant_id');
    if ($_column == null) return null;
    final manager = $$PlantsTableTableTableManager($_db, $_db.plantsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentPlantIdTable($_db));
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

  static MultiTypedResultKey<$RemindersTableTable, List<RemindersTableData>>
      _remindersTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.remindersTable,
              aliasName: 'plants__id__reminders__plant_id');

  $$RemindersTableTableProcessedTableManager get remindersTableRefs {
    final manager = $$RemindersTableTableTableManager($_db, $_db.remindersTable)
        .filter((f) => f.plantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersTableRefsTable($_db));
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

  ColumnFilters<DateTime> get lastIrrigatedAt => $composableBuilder(
      column: $table.lastIrrigatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPesticideAppliedAt => $composableBuilder(
      column: $table.lastPesticideAppliedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pesticideReapplicationDays => $composableBuilder(
      column: $table.pesticideReapplicationDays,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PlantStatus, PlantStatus, String> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get statusChangedAt => $composableBuilder(
      column: $table.statusChangedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPhotoId => $composableBuilder(
      column: $table.coverPhotoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

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

  $$PlantsTableTableFilterComposer get parentPlantId {
    final $$PlantsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentPlantId,
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

  Expression<bool> remindersTableRefs(
      Expression<bool> Function($$RemindersTableTableFilterComposer f) f) {
    final $$RemindersTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.remindersTable,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableTableFilterComposer(
              $db: $db,
              $table: $db.remindersTable,
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

  ColumnOrderings<DateTime> get lastIrrigatedAt => $composableBuilder(
      column: $table.lastIrrigatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPesticideAppliedAt => $composableBuilder(
      column: $table.lastPesticideAppliedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pesticideReapplicationDays => $composableBuilder(
      column: $table.pesticideReapplicationDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get statusChangedAt => $composableBuilder(
      column: $table.statusChangedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPhotoId => $composableBuilder(
      column: $table.coverPhotoId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

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

  $$PlantsTableTableOrderingComposer get parentPlantId {
    final $$PlantsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentPlantId,
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

  GeneratedColumn<DateTime> get lastIrrigatedAt => $composableBuilder(
      column: $table.lastIrrigatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPesticideAppliedAt => $composableBuilder(
      column: $table.lastPesticideAppliedAt, builder: (column) => column);

  GeneratedColumn<int> get pesticideReapplicationDays => $composableBuilder(
      column: $table.pesticideReapplicationDays, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlantStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get statusChangedAt => $composableBuilder(
      column: $table.statusChangedAt, builder: (column) => column);

  GeneratedColumn<String> get coverPhotoId => $composableBuilder(
      column: $table.coverPhotoId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

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

  $$PlantsTableTableAnnotationComposer get parentPlantId {
    final $$PlantsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentPlantId,
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

  Expression<T> remindersTableRefs<T extends Object>(
      Expression<T> Function($$RemindersTableTableAnnotationComposer a) f) {
    final $$RemindersTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.remindersTable,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableTableAnnotationComposer(
              $db: $db,
              $table: $db.remindersTable,
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
        bool parentPlantId,
        bool entriesTableRefs,
        bool remindersTableRefs})> {
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
            Value<String?> locationId = const Value.absent(),
            Value<DateTime?> lastIrrigatedAt = const Value.absent(),
            Value<DateTime?> lastPesticideAppliedAt = const Value.absent(),
            Value<int?> pesticideReapplicationDays = const Value.absent(),
            Value<PlantStatus> status = const Value.absent(),
            Value<DateTime?> statusChangedAt = const Value.absent(),
            Value<String?> parentPlantId = const Value.absent(),
            Value<String?> coverPhotoId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlantsTableCompanion(
            id: id,
            speciesId: speciesId,
            nickname: nickname,
            soilType: soilType,
            irrigationFrequencyDays: irrigationFrequencyDays,
            acquisitionDate: acquisitionDate,
            locationId: locationId,
            lastIrrigatedAt: lastIrrigatedAt,
            lastPesticideAppliedAt: lastPesticideAppliedAt,
            pesticideReapplicationDays: pesticideReapplicationDays,
            status: status,
            statusChangedAt: statusChangedAt,
            parentPlantId: parentPlantId,
            coverPhotoId: coverPhotoId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String speciesId,
            required String nickname,
            required String soilType,
            Value<int?> irrigationFrequencyDays = const Value.absent(),
            required DateTime acquisitionDate,
            Value<String?> locationId = const Value.absent(),
            Value<DateTime?> lastIrrigatedAt = const Value.absent(),
            Value<DateTime?> lastPesticideAppliedAt = const Value.absent(),
            Value<int?> pesticideReapplicationDays = const Value.absent(),
            Value<PlantStatus> status = const Value.absent(),
            Value<DateTime?> statusChangedAt = const Value.absent(),
            Value<String?> parentPlantId = const Value.absent(),
            Value<String?> coverPhotoId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlantsTableCompanion.insert(
            id: id,
            speciesId: speciesId,
            nickname: nickname,
            soilType: soilType,
            irrigationFrequencyDays: irrigationFrequencyDays,
            acquisitionDate: acquisitionDate,
            locationId: locationId,
            lastIrrigatedAt: lastIrrigatedAt,
            lastPesticideAppliedAt: lastPesticideAppliedAt,
            pesticideReapplicationDays: pesticideReapplicationDays,
            status: status,
            statusChangedAt: statusChangedAt,
            parentPlantId: parentPlantId,
            coverPhotoId: coverPhotoId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
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
              parentPlantId = false,
              entriesTableRefs = false,
              remindersTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (entriesTableRefs) db.entriesTable,
                if (remindersTableRefs) db.remindersTable
              ],
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
                if (parentPlantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentPlantId,
                    referencedTable:
                        $$PlantsTableTableReferences._parentPlantIdTable(db),
                    referencedColumn:
                        $$PlantsTableTableReferences._parentPlantIdTable(db).id,
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
                        typedResults: items),
                  if (remindersTableRefs)
                    await $_getPrefetchedData<PlantsTableData,
                            $PlantsTableTable, RemindersTableData>(
                        currentTable: table,
                        referencedTable: $$PlantsTableTableReferences
                            ._remindersTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlantsTableTableReferences(db, table, p0)
                                .remindersTableRefs,
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
        bool parentPlantId,
        bool entriesTableRefs,
        bool remindersTableRefs})>;
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
  Value<String?> deviceId,
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
  Value<String?> deviceId,
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

  static MultiTypedResultKey<$EntryPhotosTableTable, List<EntryPhotosTableData>>
      _entryPhotosTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.entryPhotosTable,
              aliasName: 'entries__id__entry_photos__entry_id');

  $$EntryPhotosTableTableProcessedTableManager get entryPhotosTableRefs {
    final manager =
        $$EntryPhotosTableTableTableManager($_db, $_db.entryPhotosTable)
            .filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_entryPhotosTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
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

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

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

  Expression<bool> entryPhotosTableRefs(
      Expression<bool> Function($$EntryPhotosTableTableFilterComposer f) f) {
    final $$EntryPhotosTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entryPhotosTable,
        getReferencedColumn: (t) => t.entryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntryPhotosTableTableFilterComposer(
              $db: $db,
              $table: $db.entryPhotosTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

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

  Expression<T> entryPhotosTableRefs<T extends Object>(
      Expression<T> Function($$EntryPhotosTableTableAnnotationComposer a) f) {
    final $$EntryPhotosTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entryPhotosTable,
        getReferencedColumn: (t) => t.entryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntryPhotosTableTableAnnotationComposer(
              $db: $db,
              $table: $db.entryPhotosTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
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
    PrefetchHooks Function({bool plantId, bool entryPhotosTableRefs})> {
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
            Value<String?> deviceId = const Value.absent(),
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
            deviceId: deviceId,
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
            Value<String?> deviceId = const Value.absent(),
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
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EntriesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {plantId = false, entryPhotosTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (entryPhotosTableRefs) db.entryPhotosTable
              ],
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
                return [
                  if (entryPhotosTableRefs)
                    await $_getPrefetchedData<EntriesTableData,
                            $EntriesTableTable, EntryPhotosTableData>(
                        currentTable: table,
                        referencedTable: $$EntriesTableTableReferences
                            ._entryPhotosTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EntriesTableTableReferences(db, table, p0)
                                .entryPhotosTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.entryId == item.id),
                        typedResults: items)
                ];
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
    PrefetchHooks Function({bool plantId, bool entryPhotosTableRefs})>;
typedef $$EntryPhotosTableTableCreateCompanionBuilder
    = EntryPhotosTableCompanion Function({
  required String id,
  required String entryId,
  required String photoPath,
  Value<int> position,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$EntryPhotosTableTableUpdateCompanionBuilder
    = EntryPhotosTableCompanion Function({
  Value<String> id,
  Value<String> entryId,
  Value<String> photoPath,
  Value<int> position,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
  Value<int> rowid,
});

final class $$EntryPhotosTableTableReferences extends BaseReferences<
    _$AppDatabase, $EntryPhotosTableTable, EntryPhotosTableData> {
  $$EntryPhotosTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTableTable _entryIdTable(_$AppDatabase db) =>
      db.entriesTable.createAlias('entry_photos__entry_id__entries__id');

  $$EntriesTableTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$EntriesTableTableTableManager($_db, $_db.entriesTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EntryPhotosTableTableFilterComposer
    extends Composer<_$AppDatabase, $EntryPhotosTableTable> {
  $$EntryPhotosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  $$EntriesTableTableFilterComposer get entryId {
    final $$EntriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.entryId,
        referencedTable: $db.entriesTable,
        getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$EntryPhotosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryPhotosTableTable> {
  $$EntryPhotosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  $$EntriesTableTableOrderingComposer get entryId {
    final $$EntriesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.entryId,
        referencedTable: $db.entriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableTableOrderingComposer(
              $db: $db,
              $table: $db.entriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EntryPhotosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryPhotosTableTable> {
  $$EntryPhotosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  $$EntriesTableTableAnnotationComposer get entryId {
    final $$EntriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.entryId,
        referencedTable: $db.entriesTable,
        getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$EntryPhotosTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntryPhotosTableTable,
    EntryPhotosTableData,
    $$EntryPhotosTableTableFilterComposer,
    $$EntryPhotosTableTableOrderingComposer,
    $$EntryPhotosTableTableAnnotationComposer,
    $$EntryPhotosTableTableCreateCompanionBuilder,
    $$EntryPhotosTableTableUpdateCompanionBuilder,
    (EntryPhotosTableData, $$EntryPhotosTableTableReferences),
    EntryPhotosTableData,
    PrefetchHooks Function({bool entryId})> {
  $$EntryPhotosTableTableTableManager(
      _$AppDatabase db, $EntryPhotosTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryPhotosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryPhotosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryPhotosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryId = const Value.absent(),
            Value<String> photoPath = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntryPhotosTableCompanion(
            id: id,
            entryId: entryId,
            photoPath: photoPath,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryId,
            required String photoPath,
            Value<int> position = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntryPhotosTableCompanion.insert(
            id: id,
            entryId: entryId,
            photoPath: photoPath,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EntryPhotosTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
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
                if (entryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.entryId,
                    referencedTable:
                        $$EntryPhotosTableTableReferences._entryIdTable(db),
                    referencedColumn:
                        $$EntryPhotosTableTableReferences._entryIdTable(db).id,
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

typedef $$EntryPhotosTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntryPhotosTableTable,
    EntryPhotosTableData,
    $$EntryPhotosTableTableFilterComposer,
    $$EntryPhotosTableTableOrderingComposer,
    $$EntryPhotosTableTableAnnotationComposer,
    $$EntryPhotosTableTableCreateCompanionBuilder,
    $$EntryPhotosTableTableUpdateCompanionBuilder,
    (EntryPhotosTableData, $$EntryPhotosTableTableReferences),
    EntryPhotosTableData,
    PrefetchHooks Function({bool entryId})>;
typedef $$DefensivosTableTableCreateCompanionBuilder = DefensivosTableCompanion
    Function({
  required String id,
  required String name,
  Value<String?> category,
  Value<String?> customCategoryLabel,
  Value<String?> composition,
  Value<int?> carenciaDays,
  Value<String?> imagePath,
  Value<String?> imageSource,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$DefensivosTableTableUpdateCompanionBuilder = DefensivosTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> category,
  Value<String?> customCategoryLabel,
  Value<String?> composition,
  Value<int?> carenciaDays,
  Value<String?> imagePath,
  Value<String?> imageSource,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$DefensivosTableTableFilterComposer
    extends Composer<_$AppDatabase, $DefensivosTableTable> {
  $$DefensivosTableTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customCategoryLabel => $composableBuilder(
      column: $table.customCategoryLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get carenciaDays => $composableBuilder(
      column: $table.carenciaDays, builder: (column) => ColumnFilters(column));

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

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$DefensivosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DefensivosTableTable> {
  $$DefensivosTableTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customCategoryLabel => $composableBuilder(
      column: $table.customCategoryLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get carenciaDays => $composableBuilder(
      column: $table.carenciaDays,
      builder: (column) => ColumnOrderings(column));

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

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$DefensivosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DefensivosTableTable> {
  $$DefensivosTableTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get customCategoryLabel => $composableBuilder(
      column: $table.customCategoryLabel, builder: (column) => column);

  GeneratedColumn<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => column);

  GeneratedColumn<int> get carenciaDays => $composableBuilder(
      column: $table.carenciaDays, builder: (column) => column);

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

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$DefensivosTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DefensivosTableTable,
    DefensivosTableData,
    $$DefensivosTableTableFilterComposer,
    $$DefensivosTableTableOrderingComposer,
    $$DefensivosTableTableAnnotationComposer,
    $$DefensivosTableTableCreateCompanionBuilder,
    $$DefensivosTableTableUpdateCompanionBuilder,
    (
      DefensivosTableData,
      BaseReferences<_$AppDatabase, $DefensivosTableTable, DefensivosTableData>
    ),
    DefensivosTableData,
    PrefetchHooks Function()> {
  $$DefensivosTableTableTableManager(
      _$AppDatabase db, $DefensivosTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DefensivosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DefensivosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DefensivosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> customCategoryLabel = const Value.absent(),
            Value<String?> composition = const Value.absent(),
            Value<int?> carenciaDays = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> imageSource = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DefensivosTableCompanion(
            id: id,
            name: name,
            category: category,
            customCategoryLabel: customCategoryLabel,
            composition: composition,
            carenciaDays: carenciaDays,
            imagePath: imagePath,
            imageSource: imageSource,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> category = const Value.absent(),
            Value<String?> customCategoryLabel = const Value.absent(),
            Value<String?> composition = const Value.absent(),
            Value<int?> carenciaDays = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> imageSource = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DefensivosTableCompanion.insert(
            id: id,
            name: name,
            category: category,
            customCategoryLabel: customCategoryLabel,
            composition: composition,
            carenciaDays: carenciaDays,
            imagePath: imagePath,
            imageSource: imageSource,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DefensivosTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DefensivosTableTable,
    DefensivosTableData,
    $$DefensivosTableTableFilterComposer,
    $$DefensivosTableTableOrderingComposer,
    $$DefensivosTableTableAnnotationComposer,
    $$DefensivosTableTableCreateCompanionBuilder,
    $$DefensivosTableTableUpdateCompanionBuilder,
    (
      DefensivosTableData,
      BaseReferences<_$AppDatabase, $DefensivosTableTable, DefensivosTableData>
    ),
    DefensivosTableData,
    PrefetchHooks Function()>;
typedef $$RemindersTableTableCreateCompanionBuilder = RemindersTableCompanion
    Function({
  required String id,
  required String plantId,
  required EntryType entryType,
  required int intervalDays,
  Value<bool> enabled,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$RemindersTableTableUpdateCompanionBuilder = RemindersTableCompanion
    Function({
  Value<String> id,
  Value<String> plantId,
  Value<EntryType> entryType,
  Value<int> intervalDays,
  Value<bool> enabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> localRev,
  Value<String?> deviceId,
  Value<int> rowid,
});

final class $$RemindersTableTableReferences extends BaseReferences<
    _$AppDatabase, $RemindersTableTable, RemindersTableData> {
  $$RemindersTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PlantsTableTable _plantIdTable(_$AppDatabase db) =>
      db.plantsTable.createAlias('reminders__plant_id__plants__id');

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

class $$RemindersTableTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EntryType, EntryType, String> get entryType =>
      $composableBuilder(
          column: $table.entryType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

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

class $$RemindersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localRev => $composableBuilder(
      column: $table.localRev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

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

class $$RemindersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EntryType, String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

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

class $$RemindersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTableTable,
    RemindersTableData,
    $$RemindersTableTableFilterComposer,
    $$RemindersTableTableOrderingComposer,
    $$RemindersTableTableAnnotationComposer,
    $$RemindersTableTableCreateCompanionBuilder,
    $$RemindersTableTableUpdateCompanionBuilder,
    (RemindersTableData, $$RemindersTableTableReferences),
    RemindersTableData,
    PrefetchHooks Function({bool plantId})> {
  $$RemindersTableTableTableManager(
      _$AppDatabase db, $RemindersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> plantId = const Value.absent(),
            Value<EntryType> entryType = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersTableCompanion(
            id: id,
            plantId: plantId,
            entryType: entryType,
            intervalDays: intervalDays,
            enabled: enabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String plantId,
            required EntryType entryType,
            required int intervalDays,
            Value<bool> enabled = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> localRev = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersTableCompanion.insert(
            id: id,
            plantId: plantId,
            entryType: entryType,
            intervalDays: intervalDays,
            enabled: enabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            localRev: localRev,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RemindersTableTableReferences(db, table, e)
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
                        $$RemindersTableTableReferences._plantIdTable(db),
                    referencedColumn:
                        $$RemindersTableTableReferences._plantIdTable(db).id,
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

typedef $$RemindersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTableTable,
    RemindersTableData,
    $$RemindersTableTableFilterComposer,
    $$RemindersTableTableOrderingComposer,
    $$RemindersTableTableAnnotationComposer,
    $$RemindersTableTableCreateCompanionBuilder,
    $$RemindersTableTableUpdateCompanionBuilder,
    (RemindersTableData, $$RemindersTableTableReferences),
    RemindersTableData,
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
typedef $$SyncEntryTypesTableTableCreateCompanionBuilder
    = SyncEntryTypesTableCompanion Function({
  required String peerId,
  required String entryType,
  Value<int> rowid,
});
typedef $$SyncEntryTypesTableTableUpdateCompanionBuilder
    = SyncEntryTypesTableCompanion Function({
  Value<String> peerId,
  Value<String> entryType,
  Value<int> rowid,
});

class $$SyncEntryTypesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEntryTypesTableTable> {
  $$SyncEntryTypesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));
}

class $$SyncEntryTypesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEntryTypesTableTable> {
  $$SyncEntryTypesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));
}

class $$SyncEntryTypesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEntryTypesTableTable> {
  $$SyncEntryTypesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);
}

class $$SyncEntryTypesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncEntryTypesTableTable,
    SyncEntryTypesTableData,
    $$SyncEntryTypesTableTableFilterComposer,
    $$SyncEntryTypesTableTableOrderingComposer,
    $$SyncEntryTypesTableTableAnnotationComposer,
    $$SyncEntryTypesTableTableCreateCompanionBuilder,
    $$SyncEntryTypesTableTableUpdateCompanionBuilder,
    (
      SyncEntryTypesTableData,
      BaseReferences<_$AppDatabase, $SyncEntryTypesTableTable,
          SyncEntryTypesTableData>
    ),
    SyncEntryTypesTableData,
    PrefetchHooks Function()> {
  $$SyncEntryTypesTableTableTableManager(
      _$AppDatabase db, $SyncEntryTypesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEntryTypesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEntryTypesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEntryTypesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> peerId = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncEntryTypesTableCompanion(
            peerId: peerId,
            entryType: entryType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String peerId,
            required String entryType,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncEntryTypesTableCompanion.insert(
            peerId: peerId,
            entryType: entryType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncEntryTypesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncEntryTypesTableTable,
    SyncEntryTypesTableData,
    $$SyncEntryTypesTableTableFilterComposer,
    $$SyncEntryTypesTableTableOrderingComposer,
    $$SyncEntryTypesTableTableAnnotationComposer,
    $$SyncEntryTypesTableTableCreateCompanionBuilder,
    $$SyncEntryTypesTableTableUpdateCompanionBuilder,
    (
      SyncEntryTypesTableData,
      BaseReferences<_$AppDatabase, $SyncEntryTypesTableTable,
          SyncEntryTypesTableData>
    ),
    SyncEntryTypesTableData,
    PrefetchHooks Function()>;
typedef $$SyncEntityTypesTableTableCreateCompanionBuilder
    = SyncEntityTypesTableCompanion Function({
  required String peerId,
  required String entityType,
  Value<int> rowid,
});
typedef $$SyncEntityTypesTableTableUpdateCompanionBuilder
    = SyncEntityTypesTableCompanion Function({
  Value<String> peerId,
  Value<String> entityType,
  Value<int> rowid,
});

class $$SyncEntityTypesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEntityTypesTableTable> {
  $$SyncEntityTypesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));
}

class $$SyncEntityTypesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEntityTypesTableTable> {
  $$SyncEntityTypesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));
}

class $$SyncEntityTypesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEntityTypesTableTable> {
  $$SyncEntityTypesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);
}

class $$SyncEntityTypesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncEntityTypesTableTable,
    SyncEntityTypesTableData,
    $$SyncEntityTypesTableTableFilterComposer,
    $$SyncEntityTypesTableTableOrderingComposer,
    $$SyncEntityTypesTableTableAnnotationComposer,
    $$SyncEntityTypesTableTableCreateCompanionBuilder,
    $$SyncEntityTypesTableTableUpdateCompanionBuilder,
    (
      SyncEntityTypesTableData,
      BaseReferences<_$AppDatabase, $SyncEntityTypesTableTable,
          SyncEntityTypesTableData>
    ),
    SyncEntityTypesTableData,
    PrefetchHooks Function()> {
  $$SyncEntityTypesTableTableTableManager(
      _$AppDatabase db, $SyncEntityTypesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEntityTypesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEntityTypesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEntityTypesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> peerId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncEntityTypesTableCompanion(
            peerId: peerId,
            entityType: entityType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String peerId,
            required String entityType,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncEntityTypesTableCompanion.insert(
            peerId: peerId,
            entityType: entityType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncEntityTypesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SyncEntityTypesTableTable,
        SyncEntityTypesTableData,
        $$SyncEntityTypesTableTableFilterComposer,
        $$SyncEntityTypesTableTableOrderingComposer,
        $$SyncEntityTypesTableTableAnnotationComposer,
        $$SyncEntityTypesTableTableCreateCompanionBuilder,
        $$SyncEntityTypesTableTableUpdateCompanionBuilder,
        (
          SyncEntityTypesTableData,
          BaseReferences<_$AppDatabase, $SyncEntityTypesTableTable,
              SyncEntityTypesTableData>
        ),
        SyncEntityTypesTableData,
        PrefetchHooks Function()>;
typedef $$SyncConfirmedEntityTypesTableTableCreateCompanionBuilder
    = SyncConfirmedEntityTypesTableCompanion Function({
  required String peerId,
  required String entityType,
  Value<int> rowid,
});
typedef $$SyncConfirmedEntityTypesTableTableUpdateCompanionBuilder
    = SyncConfirmedEntityTypesTableCompanion Function({
  Value<String> peerId,
  Value<String> entityType,
  Value<int> rowid,
});

class $$SyncConfirmedEntityTypesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConfirmedEntityTypesTableTable> {
  $$SyncConfirmedEntityTypesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));
}

class $$SyncConfirmedEntityTypesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConfirmedEntityTypesTableTable> {
  $$SyncConfirmedEntityTypesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));
}

class $$SyncConfirmedEntityTypesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConfirmedEntityTypesTableTable> {
  $$SyncConfirmedEntityTypesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);
}

class $$SyncConfirmedEntityTypesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncConfirmedEntityTypesTableTable,
    SyncConfirmedEntityTypesTableData,
    $$SyncConfirmedEntityTypesTableTableFilterComposer,
    $$SyncConfirmedEntityTypesTableTableOrderingComposer,
    $$SyncConfirmedEntityTypesTableTableAnnotationComposer,
    $$SyncConfirmedEntityTypesTableTableCreateCompanionBuilder,
    $$SyncConfirmedEntityTypesTableTableUpdateCompanionBuilder,
    (
      SyncConfirmedEntityTypesTableData,
      BaseReferences<_$AppDatabase, $SyncConfirmedEntityTypesTableTable,
          SyncConfirmedEntityTypesTableData>
    ),
    SyncConfirmedEntityTypesTableData,
    PrefetchHooks Function()> {
  $$SyncConfirmedEntityTypesTableTableTableManager(
      _$AppDatabase db, $SyncConfirmedEntityTypesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConfirmedEntityTypesTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConfirmedEntityTypesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConfirmedEntityTypesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> peerId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConfirmedEntityTypesTableCompanion(
            peerId: peerId,
            entityType: entityType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String peerId,
            required String entityType,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConfirmedEntityTypesTableCompanion.insert(
            peerId: peerId,
            entityType: entityType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncConfirmedEntityTypesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SyncConfirmedEntityTypesTableTable,
        SyncConfirmedEntityTypesTableData,
        $$SyncConfirmedEntityTypesTableTableFilterComposer,
        $$SyncConfirmedEntityTypesTableTableOrderingComposer,
        $$SyncConfirmedEntityTypesTableTableAnnotationComposer,
        $$SyncConfirmedEntityTypesTableTableCreateCompanionBuilder,
        $$SyncConfirmedEntityTypesTableTableUpdateCompanionBuilder,
        (
          SyncConfirmedEntityTypesTableData,
          BaseReferences<_$AppDatabase, $SyncConfirmedEntityTypesTableTable,
              SyncConfirmedEntityTypesTableData>
        ),
        SyncConfirmedEntityTypesTableData,
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
  $$EntryPhotosTableTableTableManager get entryPhotosTable =>
      $$EntryPhotosTableTableTableManager(_db, _db.entryPhotosTable);
  $$DefensivosTableTableTableManager get defensivosTable =>
      $$DefensivosTableTableTableManager(_db, _db.defensivosTable);
  $$RemindersTableTableTableManager get remindersTable =>
      $$RemindersTableTableTableManager(_db, _db.remindersTable);
  $$SyncMetaTableTableTableManager get syncMetaTable =>
      $$SyncMetaTableTableTableManager(_db, _db.syncMetaTable);
  $$SyncCursorsTableTableTableManager get syncCursorsTable =>
      $$SyncCursorsTableTableTableManager(_db, _db.syncCursorsTable);
  $$SyncEntryTypesTableTableTableManager get syncEntryTypesTable =>
      $$SyncEntryTypesTableTableTableManager(_db, _db.syncEntryTypesTable);
  $$SyncEntityTypesTableTableTableManager get syncEntityTypesTable =>
      $$SyncEntityTypesTableTableTableManager(_db, _db.syncEntityTypesTable);
  $$SyncConfirmedEntityTypesTableTableTableManager
      get syncConfirmedEntityTypesTable =>
          $$SyncConfirmedEntityTypesTableTableTableManager(
              _db, _db.syncConfirmedEntityTypesTable);
}
