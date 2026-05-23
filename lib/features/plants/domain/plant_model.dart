import 'dart:convert';

import '../../../core/enums.dart';
import '../../locations/domain/location_model.dart';
import '../../species/domain/species_model.dart';

class PlantModel {
  final String id;
  final String speciesId;
  final String nickname;
  final SoilType soilType;

  /// Null means: use species.defaultIrrigationFrequencyDays
  final int? irrigationFrequencyDays;
  final DateTime acquisitionDate;
  final String? location;
  final String? locationId;
  final DateTime? lastIrrigatedAt;
  final DateTime createdAt;
  // TODO(sync): Used by the sync layer to determine pending changes
  final SyncStatus syncStatus;

  const PlantModel({
    required this.id,
    required this.speciesId,
    required this.nickname,
    required this.soilType,
    this.irrigationFrequencyDays,
    required this.acquisitionDate,
    this.location,
    this.locationId,
    this.lastIrrigatedAt,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  PlantModel copyWith({
    String? id,
    String? speciesId,
    String? nickname,
    SoilType? soilType,
    Object? irrigationFrequencyDays = _sentinel,
    DateTime? acquisitionDate,
    Object? location = _sentinel,
    Object? locationId = _sentinel,
    Object? lastIrrigatedAt = _sentinel,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) =>
      PlantModel(
        id: id ?? this.id,
        speciesId: speciesId ?? this.speciesId,
        nickname: nickname ?? this.nickname,
        soilType: soilType ?? this.soilType,
        irrigationFrequencyDays: irrigationFrequencyDays == _sentinel
            ? this.irrigationFrequencyDays
            : irrigationFrequencyDays as int?,
        acquisitionDate: acquisitionDate ?? this.acquisitionDate,
        location: location == _sentinel ? this.location : location as String?,
        locationId:
            locationId == _sentinel ? this.locationId : locationId as String?,
        lastIrrigatedAt: lastIrrigatedAt == _sentinel
            ? this.lastIrrigatedAt
            : lastIrrigatedAt as DateTime?,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  // TODO(sync): Serialization used when enqueuing in sync_queue
  Map<String, dynamic> toJson() => {
        'id': id,
        'speciesId': speciesId,
        'nickname': nickname,
        'soilType': soilType.name,
        'irrigationFrequencyDays': irrigationFrequencyDays,
        'acquisitionDate': acquisitionDate.toIso8601String(),
        'location': location,
        'locationId': locationId,
        'lastIrrigatedAt': lastIrrigatedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  String toJsonString() => jsonEncode(toJson());
}

// Sentinel for nullable copyWith overrides
const Object _sentinel = Object();

/// Combines a plant with its resolved species for display and irrigation logic.
class PlantWithSpecies {
  final PlantModel plant;
  final SpeciesModel species;
  final LocationModel? location;

  const PlantWithSpecies({
    required this.plant,
    required this.species,
    this.location,
  });

  int get effectiveFrequencyDays =>
      plant.irrigationFrequencyDays ?? species.defaultIrrigationFrequencyDays;

  bool get needsWatering {
    if (plant.lastIrrigatedAt == null) return true;
    return daysSinceIrrigation >= effectiveFrequencyDays;
  }

  int get daysSinceIrrigation {
    if (plant.lastIrrigatedAt == null) return effectiveFrequencyDays;
    return DateTime.now().difference(plant.lastIrrigatedAt!).inDays;
  }

  /// Positive = days overdue, negative = days until due
  int get daysRelativeToSchedule =>
      daysSinceIrrigation - effectiveFrequencyDays;
}
