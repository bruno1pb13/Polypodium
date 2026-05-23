import 'dart:convert';

import '../../../core/enums.dart';

class SpeciesModel {
  final String id;
  final String scientificName;
  final String popularName;
  final int defaultIrrigationFrequencyDays;
  final List<SoilType> recommendedSoilTypes;
  // TODO(sync): Used by the sync layer to determine pending changes
  final SyncStatus syncStatus;
  final DateTime createdAt;

  const SpeciesModel({
    required this.id,
    required this.scientificName,
    required this.popularName,
    required this.defaultIrrigationFrequencyDays,
    required this.recommendedSoilTypes,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
  });

  SpeciesModel copyWith({
    String? id,
    String? scientificName,
    String? popularName,
    int? defaultIrrigationFrequencyDays,
    List<SoilType>? recommendedSoilTypes,
    SyncStatus? syncStatus,
    DateTime? createdAt,
  }) =>
      SpeciesModel(
        id: id ?? this.id,
        scientificName: scientificName ?? this.scientificName,
        popularName: popularName ?? this.popularName,
        defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays ??
            this.defaultIrrigationFrequencyDays,
        recommendedSoilTypes: recommendedSoilTypes ?? this.recommendedSoilTypes,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );

  // TODO(sync): Serialization used when enqueuing in sync_queue
  Map<String, dynamic> toJson() => {
        'id': id,
        'scientificName': scientificName,
        'popularName': popularName,
        'defaultIrrigationFrequencyDays': defaultIrrigationFrequencyDays,
        'recommendedSoilTypes':
            recommendedSoilTypes.map((s) => s.name).toList(),
        'syncStatus': syncStatus.name,
        'createdAt': createdAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());
}
