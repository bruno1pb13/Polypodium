import '../../../core/links/app_link.dart';
import '../../locations/domain/location_model.dart';
import '../../plants/domain/plant_model.dart';
import '../../species/domain/species_model.dart';

/// What goes on a plant's printed label.
class PlantLabel {
  const PlantLabel({
    required this.plantId,
    required this.shortCode,
    required this.nickname,
    this.popularName,
    this.scientificName,
    this.location,
    required this.acquisitionDate,
  });

  factory PlantLabel.of(
    PlantModel plant, {
    SpeciesModel? species,
    LocationModel? location,
  }) =>
      PlantLabel(
        plantId: plant.id,
        shortCode: plant.shortCode,
        nickname: plant.nickname,
        popularName: species?.popularName,
        scientificName: species?.scientificName,
        location: location?.name,
        acquisitionDate: plant.acquisitionDate,
      );

  final String plantId;

  /// Printed under the names, for finding the plant without the QR code.
  final String shortCode;
  final String nickname;
  final String? popularName;
  final String? scientificName;
  final String? location;
  final DateTime acquisitionDate;

  /// Encoded in the label's QR code.
  String get link => AppLink.plantUri(plantId).toString();
}

/// Sheet layouts offered for printing: A4 pages split into a grid of
/// labels (common pre-cut sticker sheets), centered on the page.
enum LabelSheetPreset {
  /// 24 labels of 70 × 37 mm.
  a4x24(columns: 3, rows: 8, widthMm: 70, heightMm: 37),

  /// 10 labels of 99 × 57 mm.
  a4x10(columns: 2, rows: 5, widthMm: 99, heightMm: 57);

  const LabelSheetPreset({
    required this.columns,
    required this.rows,
    required this.widthMm,
    required this.heightMm,
  });

  static const pageWidthMm = 210.0;
  static const pageHeightMm = 297.0;

  final int columns;
  final int rows;
  final double widthMm;
  final double heightMm;

  int get perPage => columns * rows;

  int pagesFor(int labelCount) => (labelCount / perPage).ceil();
}

/// Which optional lines a label shows.
class LabelOptions {
  const LabelOptions({
    this.preset = LabelSheetPreset.a4x24,
    this.showLocation = true,
    this.showAcquisitionDate = false,
  });

  final LabelSheetPreset preset;
  final bool showLocation;
  final bool showAcquisitionDate;

  LabelOptions copyWith({
    LabelSheetPreset? preset,
    bool? showLocation,
    bool? showAcquisitionDate,
  }) =>
      LabelOptions(
        preset: preset ?? this.preset,
        showLocation: showLocation ?? this.showLocation,
        showAcquisitionDate: showAcquisitionDate ?? this.showAcquisitionDate,
      );
}
