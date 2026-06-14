import 'dart:convert';

import '../../../core/enums.dart';

class EntryModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String? photoPath;
  final String? note;
  final EntryType type;
  // Numeric measurement: height in cm, chlorosis severity (1–3), etc.
  final double? numericValue;
  // JSON string for extra structured fields (e.g. pest type)
  final String? extraData;
  final DateTime createdAt;
  // TODO(sync): Used by the sync layer to determine pending changes
  final SyncStatus syncStatus;

  const EntryModel({
    required this.id,
    required this.plantId,
    required this.date,
    this.photoPath,
    this.note,
    required this.type,
    this.numericValue,
    this.extraData,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  EntryModel copyWith({
    String? id,
    String? plantId,
    DateTime? date,
    Object? photoPath = _sentinel,
    Object? note = _sentinel,
    EntryType? type,
    Object? numericValue = _sentinel,
    Object? extraData = _sentinel,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) =>
      EntryModel(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        date: date ?? this.date,
        photoPath:
            photoPath == _sentinel ? this.photoPath : photoPath as String?,
        note: note == _sentinel ? this.note : note as String?,
        type: type ?? this.type,
        numericValue: numericValue == _sentinel
            ? this.numericValue
            : numericValue as double?,
        extraData:
            extraData == _sentinel ? this.extraData : extraData as String?,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  // TODO(sync): Serialization used when enqueuing in sync_queue
  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        'date': date.toIso8601String(),
        'photoPath': photoPath,
        'note': note,
        'type': type.name,
        'numericValue': numericValue,
        'extraData': extraData,
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  String toJsonString() => jsonEncode(toJson());
}

const Object _sentinel = Object();
