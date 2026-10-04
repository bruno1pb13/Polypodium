import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plant_search_providers.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

PlantModel _plant(String id, PlantStatus status, {String speciesId = 's1'}) =>
    PlantModel(
      id: id,
      speciesId: speciesId,
      nickname: id,
      soilId: 'loamy',
      acquisitionDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      status: status,
    );

class FakePlantsNotifier extends PlantsNotifier {
  FakePlantsNotifier(this.plants);
  final List<PlantModel> plants;

  @override
  Stream<List<PlantModel>> build() => Stream.value(plants);
}

void main() {
  final species = SpeciesModel(
    id: 's1',
    popularName: 'Fern',
    scientificName: 'Polypodium',
    defaultIrrigationFrequencyDays: 3,
    recommendedSoilIds: const [],
    createdAt: DateTime(2026, 1, 1),
  );

  group('filteredSortedPlants', () {
    late ProviderContainer container;

    setUp(() {
      final plants = [
        for (final status in PlantStatus.values)
          PlantWithSpecies(
              plant: _plant(status.name, status), species: species),
      ];
      container = ProviderContainer(overrides: [
        plantsWithSpeciesProvider.overrideWith((ref) async => plants),
      ]);
      container.listen(filteredSortedPlantsProvider, (_, __) {});
    });

    tearDown(() => container.dispose());

    test('hides plants that are not active by default', () async {
      final plants = await container.read(filteredSortedPlantsProvider.future);
      expect(plants.map((p) => p.plant.id), ['active']);
    });

    test('shows every status once "show archived" is on', () async {
      container.read(plantShowArchivedNotifierProvider.notifier).toggle();

      final plants = await container.read(filteredSortedPlantsProvider.future);
      expect(plants.map((p) => p.plant.id),
          unorderedEquals(PlantStatus.values.map((s) => s.name)));
    });
  });

  group('speciesSurvival', () {
    test('counts every plant of the species but the dead ones as alive',
        () async {
      final container = ProviderContainer(overrides: [
        plantsNotifierProvider.overrideWith(() => FakePlantsNotifier([
              _plant('a', PlantStatus.active),
              _plant('b', PlantStatus.archived),
              _plant('c', PlantStatus.donated),
              _plant('d', PlantStatus.dead),
              _plant('e', PlantStatus.dead, speciesId: 's2'),
            ])),
      ]);
      addTearDown(container.dispose);
      container.listen(speciesSurvivalProvider('s1'), (_, __) {});

      final survival =
          await container.read(speciesSurvivalProvider('s1').future);
      expect(survival.alive, 3);
      expect(survival.total, 4);
    });
  });
}
