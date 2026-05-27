import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

void main() {
  group('Plant Filter and Sort Logic', () {
    final species1 = SpeciesModel(
      id: 's1',
      popularName: 'Rose',
      scientificName: 'Rosa',
      defaultIrrigationFrequencyDays: 3,
      recommendedSoilIds: ['loamy'],
      createdAt: DateTime.now(),
    );

    final species2 = SpeciesModel(
      id: 's2',
      popularName: 'Cactus',
      scientificName: 'Cactaceae',
      defaultIrrigationFrequencyDays: 10,
      recommendedSoilIds: ['sandy'],
      createdAt: DateTime.now(),
    );

    final plants = [
      PlantWithSpecies(
        plant: PlantModel(
          id: 'p1',
          speciesId: 's1',
          nickname: 'Red Rose',
          soilId: 'loamy',
          acquisitionDate: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
          lastIrrigatedAt:
              DateTime.now().subtract(const Duration(days: 4)), // Overdue
        ),
        species: species1,
      ),
      PlantWithSpecies(
        plant: PlantModel(
          id: 'p2',
          speciesId: 's2',
          nickname: 'Desert Cactus',
          soilId: 'sandy',
          acquisitionDate: DateTime(2023, 2, 1),
          createdAt: DateTime(2023, 2, 1),
          lastIrrigatedAt:
              DateTime.now().subtract(const Duration(days: 1)), // Not overdue
        ),
        species: species2,
      ),
      PlantWithSpecies(
        plant: PlantModel(
          id: 'p3',
          speciesId: 's1',
          nickname: 'White Rose',
          soilId: 'loamy',
          acquisitionDate: DateTime(2023, 3, 1),
          createdAt: DateTime(2023, 3, 1),
          lastIrrigatedAt:
              DateTime.now().subtract(const Duration(days: 5)), // More overdue
        ),
        species: species1,
      ),
    ];

    test('Filter by nickname', () {
      final query = 'red';
      final filtered = plants
          .where((p) =>
              p.plant.nickname.toLowerCase().contains(query.toLowerCase()))
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.plant.id, 'p1');
    });

    test('Sort by name A-Z', () {
      final sorted = [...plants]..sort((a, b) => a.plant.nickname
          .toLowerCase()
          .compareTo(b.plant.nickname.toLowerCase()));
      expect(sorted[0].plant.nickname, 'Desert Cactus');
      expect(sorted[1].plant.nickname, 'Red Rose');
      expect(sorted[2].plant.nickname, 'White Rose');
    });

    test('Sort by watering needs (overdue first)', () {
      final sorted = [...plants]..sort((a, b) {
          final aVal = a.daysRelativeToSchedule ?? -999;
          final bVal = b.daysRelativeToSchedule ?? -999;
          return bVal.compareTo(aVal);
        });

      // p3 is 5-3=2 days overdue
      // p1 is 4-3=1 day overdue
      // p2 is 1-10=-9 days (not overdue)

      expect(sorted[0].plant.id, 'p3');
      expect(sorted[1].plant.id, 'p1');
      expect(sorted[2].plant.id, 'p2');
    });
  });
}
