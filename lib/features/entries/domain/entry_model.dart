import '../../../core/enums.dart';
import 'entry_details.dart';

class EntryModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String? photoPath;
  final String? note;
  final EntryType type;
  // Numeric measurement: height in cm, chlorosis severity (1–3), etc.
  final double? numericValue;
  // JSON string for extra structured fields (e.g. pest type); read and
  // build it through [details] / [EntryDetails.encode].
  final String? extraData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

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
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  EntryDetails? get details => EntryDetails.decode(type, extraData);

  /// The entry's photos in order. The first one is [photoPath] and shares
  /// the entry's id.
  List<EntryPhoto> get photos =>
      [if (photoPath != null) EntryPhoto(id: id, path: photoPath!)];

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
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? localRev,
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
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
        localRev: localRev ?? this.localRev,
      );
}

const Object _sentinel = Object();

/// One photo of an entry, identified by an id that stays the same on every
/// device (its local [path] doesn't).
class EntryPhoto {
  final String id;
  final String path;

  const EntryPhoto({required this.id, required this.path});

  @override
  bool operator ==(Object other) =>
      other is EntryPhoto && other.id == id && other.path == path;

  @override
  int get hashCode => Object.hash(id, path);
}
