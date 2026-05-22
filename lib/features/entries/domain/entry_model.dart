import 'dart:convert';

import '../../../core/enums.dart';

class EntryModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String? photoPath;
  final String? note;
  final EntryType type;
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
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  String toJsonString() => jsonEncode(toJson());
}

const Object _sentinel = Object();
