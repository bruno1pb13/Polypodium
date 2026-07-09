class SoilModel {
  final String id;
  final String name;
  final String? composition;
  final String? imagePath;
  final String? imageSource;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final bool isSeeded;

  const SoilModel({
    required this.id,
    required this.name,
    this.composition,
    this.imagePath,
    this.imageSource,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
    this.isSeeded = false,
  }) : updatedAt = updatedAt ?? createdAt;

  SoilModel copyWith({
    String? id,
    String? name,
    Object? composition = _sentinel,
    Object? imagePath = _sentinel,
    Object? imageSource = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? localRev,
    bool? isSeeded,
  }) =>
      SoilModel(
        id: id ?? this.id,
        name: name ?? this.name,
        composition: composition == _sentinel ? this.composition : composition as String?,
        imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
        imageSource: imageSource == _sentinel ? this.imageSource : imageSource as String?,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
        localRev: localRev ?? this.localRev,
        isSeeded: isSeeded ?? this.isSeeded,
      );
}

const Object _sentinel = Object();
