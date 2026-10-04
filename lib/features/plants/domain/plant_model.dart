import '../../../core/enums.dart';
import '../../../core/utils/date_utils.dart';
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
  final PlantStatus status;
  final DateTime? statusChangedAt;
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
    this.status = PlantStatus.active,
    this.statusChangedAt,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  bool get isActive => status == PlantStatus.active;

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
    PlantStatus? status,
    Object? statusChangedAt = _sentinel,
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
        status: status ?? this.status,
        statusChangedAt: statusChangedAt == _sentinel
            ? this.statusChangedAt
            : statusChangedAt as DateTime?,
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
    if (!plant.isActive) return false;
    final freq = effectiveFrequencyDays;
    if (freq == null) return false;
    if (plant.lastIrrigatedAt == null) return true;
    return daysSinceIrrigation >= freq;
  }

  int get daysSinceIrrigation {
    if (plant.lastIrrigatedAt == null) {
      return effectiveFrequencyDays ?? 0;
    }
    return calendarDaysBetween(plant.lastIrrigatedAt!);
  }

  /// Positive = days overdue, negative = days until due. Null for plants
  /// that are no longer active.
  int? get daysRelativeToSchedule {
    if (!plant.isActive) return null;
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
  /// no active pesticide reminder (or the plant is no longer active).
  int? get pesticideDaysRelative {
    if (!plant.isActive) return null;
    final freq = plant.pesticideReapplicationDays;
    final lastApplied = plant.lastPesticideAppliedAt;
    if (freq == null || lastApplied == null) return null;
    final daysSinceApplied = calendarDaysBetween(lastApplied);
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
    if (!plant.isActive) return false;
    final lastApplied = plant.lastPesticideAppliedAt;
    if (lastApplied == null) return false;
    final daysSince = calendarDaysBetween(lastApplied);
    return daysSince < pesticideActiveControlWindowDays;
  }
}
