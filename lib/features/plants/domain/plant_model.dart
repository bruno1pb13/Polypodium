import '../../locations/domain/location_model.dart';
import '../../species/domain/species_model.dart';

class PlantModel {
  final String id;
  final String speciesId;
  final String nickname;
  final String soilId;

  /// Null means: use species.defaultIrrigationFrequencyDays
  final int? irrigationFrequencyDays;
  final DateTime acquisitionDate;
  final String? location;
  final String? locationId;
  final DateTime? lastIrrigatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

  const PlantModel({
    required this.id,
    required this.speciesId,
    required this.nickname,
    required this.soilId,
    this.irrigationFrequencyDays,
    required this.acquisitionDate,
    this.location,
    this.locationId,
    this.lastIrrigatedAt,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  PlantModel copyWith({
    String? id,
    String? speciesId,
    String? nickname,
    String? soilId,
    Object? irrigationFrequencyDays = _sentinel,
    DateTime? acquisitionDate,
    Object? location = _sentinel,
    Object? locationId = _sentinel,
    Object? lastIrrigatedAt = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? localRev,
  }) =>
      PlantModel(
        id: id ?? this.id,
        speciesId: speciesId ?? this.speciesId,
        nickname: nickname ?? this.nickname,
        soilId: soilId ?? this.soilId,
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
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
        localRev: localRev ?? this.localRev,
      );
}

// Sentinel for nullable copyWith overrides
const Object _sentinel = Object();

/// Combines a plant with its resolved species for display and irrigation logic.
class PlantWithSpecies {
  final PlantModel plant;
  final SpeciesModel species;
  final LocationModel? location;
  final bool isPendingSync;

  const PlantWithSpecies({
    required this.plant,
    required this.species,
    this.location,
    this.isPendingSync = false,
  });

  int? get effectiveFrequencyDays =>
      plant.irrigationFrequencyDays ?? species.defaultIrrigationFrequencyDays;

  bool get needsWatering {
    final freq = effectiveFrequencyDays;
    if (freq == null) return false;
    if (plant.lastIrrigatedAt == null) return true;
    return daysSinceIrrigation >= freq;
  }

  int get daysSinceIrrigation {
    if (plant.lastIrrigatedAt == null) {
      return effectiveFrequencyDays ?? 0;
    }
    return DateTime.now().difference(plant.lastIrrigatedAt!).inDays;
  }

  /// Positive = days overdue, negative = days until due
  int? get daysRelativeToSchedule {
    final freq = effectiveFrequencyDays;
    if (freq == null) return null;
    return daysSinceIrrigation - freq;
  }
}
