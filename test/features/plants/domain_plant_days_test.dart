import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

void main() {
  PlantWithSpecies plantWateredAt(DateTime at) => PlantWithSpecies(
        plant: PlantModel(
          id: 'p1',
          speciesId: 's1',
          nickname: 'Fern',
          soilId: 'loamy',
          acquisitionDate: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
          lastIrrigatedAt: at,
        ),
        species: SpeciesModel(
          id: 's1',
          popularName: 'Fern',
          scientificName: 'Polypodium',
          defaultIrrigationFrequencyDays: 1,
          recommendedSoilIds: const [],
          createdAt: DateTime(2023, 1, 1),
        ),
      );

  test('watering late yesterday counts as one day ago', () {
    final now = DateTime.now();
    final lateYesterday = DateTime(now.year, now.month, now.day - 1, 23, 59);
    final p = plantWateredAt(lateYesterday);

    expect(p.daysSinceIrrigation, 1);
    expect(p.needsWatering, isTrue);
  });

  test('watering earlier today counts as zero days', () {
    final now = DateTime.now();
    final p = plantWateredAt(DateTime(now.year, now.month, now.day));

    expect(p.daysSinceIrrigation, 0);
    expect(p.needsWatering, isFalse);
  });
}
