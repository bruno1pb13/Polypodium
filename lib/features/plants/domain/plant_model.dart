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

  /// Derived from the most recent 'pesticide' entry — see
  /// PlantsRepository.refreshPesticideStatus.
  final DateTime? lastPesticideAppliedAt;
  final int? pesticideReapplicationDays;
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
    this.lastPesticideAppliedAt,
    this.pesticideReapplicationDays,
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
    Object? lastPesticideAppliedAt = _sentinel,
    Object? pesticideReapplicationDays = _sentinel,
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
        lastPesticideAppliedAt: lastPesticideAppliedAt == _sentinel
            ? this.lastPesticideAppliedAt
            : lastPesticideAppliedAt as DateTime?,
        pesticideReapplicationDays: pesticideReapplicationDays == _sentinel
            ? this.pesticideReapplicationDays
            : pesticideReapplicationDays as int?,
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

  /// Whether the most recent pesticide application requested a reapplication
  /// reminder that is now due (or overdue).
  bool get needsPesticideReapplication {
    final freq = plant.pesticideReapplicationDays;
    final lastApplied = plant.lastPesticideAppliedAt;
    if (freq == null || lastApplied == null) return false;
    return pesticideDaysRelative != null && pesticideDaysRelative! >= 0;
  }

  /// Positive = days overdue, negative = days until due, null when there's
  /// no active pesticide reminder.
  int? get pesticideDaysRelative {
    final freq = plant.pesticideReapplicationDays;
    final lastApplied = plant.lastPesticideAppliedAt;
    if (freq == null || lastApplied == null) return null;
    final daysSinceApplied = DateTime.now().difference(lastApplied).inDays;
    return daysSinceApplied - freq;
  }

  /// Days before the due date that a pesticide reminder starts counting as
  /// "approaching" for the plant detail screen's status card.
  static const pesticideApproachingWindowDays = 3;

  /// Whether the pesticide reapplication is coming up within the next
  /// [pesticideApproachingWindowDays] days, but isn't due yet (see
  /// [needsPesticideReapplication] for that). Drives the plant detail
  /// screen's status card.
  bool get pesticideReapplicationApproaching {
    final rel = pesticideDaysRelative;
    if (rel == null) return false;
    return rel < 0 && rel >= -pesticideApproachingWindowDays;
  }

  /// How many days a pesticide application still counts as an active pest-
  /// control routine for the home list badge, regardless of any
  /// reapplication schedule.
  static const pesticideActiveControlWindowDays = 45;

  /// Whether the plant had a pesticide applied recently enough
  /// ([pesticideActiveControlWindowDays]) to be flagged on the home list as
  /// currently under pest control — independent of [needsPesticideReapplication]
  /// or any reapplication reminder.
  bool get pesticideUnderActiveControl {
    final lastApplied = plant.lastPesticideAppliedAt;
    if (lastApplied == null) return false;
    final daysSince = DateTime.now().difference(lastApplied).inDays;
    return daysSince < pesticideActiveControlWindowDays;
  }
}
