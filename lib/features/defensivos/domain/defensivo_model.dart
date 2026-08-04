import '../../../core/enums.dart';

class DefensivoModel {
  final String id;
  final String name;
  final DefensivoCategory? category;

  /// Only meaningful when [category] is [DefensivoCategory.custom].
  final String? customCategoryLabel;

  /// Composition + application instructions.
  final String? composition;
  final int? carenciaDays;
  final String? imagePath;
  final String? imageSource;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

  const DefensivoModel({
    required this.id,
    required this.name,
    this.category,
    this.customCategoryLabel,
    this.composition,
    this.carenciaDays,
    this.imagePath,
    this.imageSource,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  /// Label to display: the translated predefined category, or the raw
  /// custom label when [category] is [DefensivoCategory.custom].
  String? displayCategoryLabel(String Function(DefensivoCategory) predefined) {
    if (category == null) return null;
    if (category == DefensivoCategory.custom) return customCategoryLabel;
    return predefined(category!);
  }

  DefensivoModel copyWith({
    String? id,
    String? name,
    Object? category = _sentinel,
    Object? customCategoryLabel = _sentinel,
    Object? composition = _sentinel,
    Object? carenciaDays = _sentinel,
    Object? imagePath = _sentinel,
    Object? imageSource = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? localRev,
  }) =>
      DefensivoModel(
        id: id ?? this.id,
        name: name ?? this.name,
        category:
            category == _sentinel ? this.category : category as DefensivoCategory?,
        customCategoryLabel: customCategoryLabel == _sentinel
            ? this.customCategoryLabel
            : customCategoryLabel as String?,
        composition:
            composition == _sentinel ? this.composition : composition as String?,
        carenciaDays: carenciaDays == _sentinel
            ? this.carenciaDays
            : carenciaDays as int?,
        imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
        imageSource:
            imageSource == _sentinel ? this.imageSource : imageSource as String?,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == _sentinel ? this.deletedAt : deletedAt as DateTime?,
        localRev: localRev ?? this.localRev,
      );
}

const Object _sentinel = Object();
