import 'dart:convert';

import '../../../core/enums.dart';

class LocationModel {
  final String id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  const LocationModel({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  LocationModel copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    Object? latitude = _sentinel,
    Object? longitude = _sentinel,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) =>
      LocationModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description == _sentinel
            ? this.description
            : description as String?,
        latitude:
            latitude == _sentinel ? this.latitude : latitude as double?,
        longitude:
            longitude == _sentinel ? this.longitude : longitude as double?,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  String toJsonString() => jsonEncode(toJson());
}

const Object _sentinel = Object();
