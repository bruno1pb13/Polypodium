import '../../locations/domain/location_model.dart';
import '../../plants/domain/plant_model.dart';
import 'pot_model.dart';

/// A pot with its resolved location and the live plants in it (any status),
/// for display.
class PotWithPlants {
  final PotModel pot;
  final LocationModel? location;
  final List<PlantWithSpecies> plants;

  const PotWithPlants({
    required this.pot,
    this.location,
    this.plants = const [],
  });

  /// The plants entries and watering apply to: those still in the
  /// collection.
  List<PlantWithSpecies> get activePlants => [
        for (final p in plants)
          if (p.plant.isActive) p
      ];
}
