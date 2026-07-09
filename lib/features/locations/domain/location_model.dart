class LocationModel {
  final String id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

  const LocationModel({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  LocationModel copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    Object? latitude = _sentinel,
    Object? longitude = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? localRev,
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
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
        localRev: localRev ?? this.localRev,
      );
}

const Object _sentinel = Object();
