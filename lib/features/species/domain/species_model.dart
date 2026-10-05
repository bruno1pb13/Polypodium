import '../../../core/enums.dart';

class SpeciesModel {
  final String id;
  final String scientificName;
  final String popularName;
  final int? defaultIrrigationFrequencyDays;
  final List<String> recommendedSoilIds;
  final LightRequirement? light;
  final HumidityLevel? humidity;
  final PetToxicity petToxicity;

  /// Months (1–12) in which the species usually flowers.
  final Set<int> floweringMonths;
  final String? careNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

  const SpeciesModel({
    required this.id,
    required this.scientificName,
    required this.popularName,
    required this.defaultIrrigationFrequencyDays,
    required this.recommendedSoilIds,
    this.light,
    this.humidity,
    this.petToxicity = PetToxicity.unknown,
    this.floweringMonths = const {},
    this.careNotes,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  /// Whether any field of the care sheet is filled in.
  bool get hasCareInfo =>
      light != null ||
      humidity != null ||
      petToxicity != PetToxicity.unknown ||
      floweringMonths.isNotEmpty ||
      (careNotes?.trim().isNotEmpty ?? false);

  SpeciesModel copyWith({
    String? id,
    String? scientificName,
    String? popularName,
    Object? defaultIrrigationFrequencyDays = _sentinel,
    List<String>? recommendedSoilIds,
    Object? light = _sentinel,
    Object? humidity = _sentinel,
    PetToxicity? petToxicity,
    Set<int>? floweringMonths,
    Object? careNotes = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? localRev,
  }) =>
      SpeciesModel(
        id: id ?? this.id,
        scientificName: scientificName ?? this.scientificName,
        popularName: popularName ?? this.popularName,
        defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays == _sentinel
            ? this.defaultIrrigationFrequencyDays
            : defaultIrrigationFrequencyDays as int?,
        recommendedSoilIds: recommendedSoilIds ?? this.recommendedSoilIds,
        light: light == _sentinel ? this.light : light as LightRequirement?,
        humidity:
            humidity == _sentinel ? this.humidity : humidity as HumidityLevel?,
        petToxicity: petToxicity ?? this.petToxicity,
        floweringMonths: floweringMonths ?? this.floweringMonths,
        careNotes: careNotes == _sentinel ? this.careNotes : careNotes as String?,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
        localRev: localRev ?? this.localRev,
      );
}

// Sentinel for nullable copyWith overrides
const Object _sentinel = Object();
