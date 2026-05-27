import 'dart:convert';

import '../../../core/enums.dart';

class SpeciesModel {
  final String id;
  final String scientificName;
  final String popularName;
  final int? defaultIrrigationFrequencyDays;
  final List<String> recommendedSoilIds;
  // TODO(sync): Used by the sync layer to determine pending changes
  final SyncStatus syncStatus;
  final DateTime createdAt;

  const SpeciesModel({
    required this.id,
    required this.scientificName,
    required this.popularName,
    required this.defaultIrrigationFrequencyDays,
    required this.recommendedSoilIds,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
  });

  SpeciesModel copyWith({
    String? id,
    String? scientificName,
    String? popularName,
    Object? defaultIrrigationFrequencyDays = _sentinel,
    List<String>? recommendedSoilIds,
    SyncStatus? syncStatus,
    DateTime? createdAt,
  }) =>
      SpeciesModel(
        id: id ?? this.id,
        scientificName: scientificName ?? this.scientificName,
        popularName: popularName ?? this.popularName,
        defaultIrrigationFrequencyDays: defaultIrrigationFrequencyDays == _sentinel
            ? this.defaultIrrigationFrequencyDays
            : defaultIrrigationFrequencyDays as int?,
        recommendedSoilIds: recommendedSoilIds ?? this.recommendedSoilIds,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );

  // TODO(sync): Serialization used when enqueuing in sync_queue
  Map<String, dynamic> toJson() => {
        'id': id,
        'scientificName': scientificName,
        'popularName': popularName,
        'defaultIrrigationFrequencyDays': defaultIrrigationFrequencyDays,
        'recommendedSoilIds': recommendedSoilIds,
        'syncStatus': syncStatus.name,
        'createdAt': createdAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());
}

// Sentinel for nullable copyWith overrides
const Object _sentinel = Object();
