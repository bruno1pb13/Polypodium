class SpeciesModel {
  final String id;
  final String scientificName;
  final String popularName;
  final int? defaultIrrigationFrequencyDays;
  final List<String> recommendedSoilIds;
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
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  SpeciesModel copyWith({
    String? id,
    String? scientificName,
    String? popularName,
    Object? defaultIrrigationFrequencyDays = _sentinel,
    List<String>? recommendedSoilIds,
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
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
        localRev: localRev ?? this.localRev,
      );
}

// Sentinel for nullable copyWith overrides
const Object _sentinel = Object();
