import '../../../core/enums.dart';

/// A container plants live in (see PotsTable).
class PotModel {
  final String id;
  final String name;
  final PotKind kind;
  final double? diameterCm;
  final PotMaterial? material;
  final String? locationId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

  const PotModel({
    required this.id,
    required this.name,
    this.kind = PotKind.pot,
    this.diameterCm,
    this.material,
    this.locationId,
    this.notes,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  PotModel copyWith({
    String? name,
    PotKind? kind,
    Object? diameterCm = _sentinel,
    Object? material = _sentinel,
    Object? locationId = _sentinel,
    Object? notes = _sentinel,
    DateTime? updatedAt,
  }) =>
      PotModel(
        id: id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        diameterCm:
            diameterCm == _sentinel ? this.diameterCm : diameterCm as double?,
        material:
            material == _sentinel ? this.material : material as PotMaterial?,
        locationId:
            locationId == _sentinel ? this.locationId : locationId as String?,
        notes: notes == _sentinel ? this.notes : notes as String?,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        localRev: localRev,
      );
}

const Object _sentinel = Object();
