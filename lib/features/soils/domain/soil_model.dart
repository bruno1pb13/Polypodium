import 'dart:convert';
import '../../../../core/enums.dart';

class SoilModel {
  final String id;
  final String name;
  final String? composition;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  const SoilModel({
    required this.id,
    required this.name,
    this.composition,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  SoilModel copyWith({
    String? id,
    String? name,
    Object? composition = _sentinel,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) =>
      SoilModel(
        id: id ?? this.id,
        name: name ?? this.name,
        composition: composition == _sentinel ? this.composition : composition as String?,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'composition': composition,
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory SoilModel.fromJson(Map<String, dynamic> json) => SoilModel(
        id: json['id'],
        name: json['name'],
        composition: json['composition'],
        createdAt: DateTime.parse(json['createdAt']),
        syncStatus: SyncStatus.values.byName(json['syncStatus'] ?? 'pending'),
      );

  String toJsonString() => jsonEncode(toJson());
}

const Object _sentinel = Object();
