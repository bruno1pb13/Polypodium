import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/plants_repository.dart';
import '../../domain/plant_model.dart';
import '../../../species/presentation/providers/species_providers.dart';

part 'plants_providers.g.dart';

@Riverpod(keepAlive: true)
PlantsRepository plantsRepository(PlantsRepositoryRef ref) {
  return PlantsRepository(ref.watch(appDatabaseProvider));
}

@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  @override
  Future<List<PlantModel>> build() =>
      ref.watch(plantsRepositoryProvider).getAll();

  Future<void> save(PlantModel plant) async {
    await ref.read(plantsRepositoryProvider).save(plant);
    ref.invalidateSelf();
    await future;
  }

  Future<void> irrigate(String plantId) async {
    await ref.read(plantsRepositoryProvider).irrigate(plantId);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String plantId) async {
    await ref.read(plantsRepositoryProvider).delete(plantId);
    ref.invalidateSelf();
    await future;
  }
}

/// Combines each plant with its resolved species for home-screen display.
@riverpod
Future<List<PlantWithSpecies>> plantsWithSpecies(
    PlantsWithSpeciesRef ref) async {
  final plants = await ref.watch(plantsNotifierProvider.future);
  final species = await ref.watch(speciesNotifierProvider.future);

  final speciesById = {for (final s in species) s.id: s};
  return plants
      .where((p) => speciesById.containsKey(p.speciesId))
      .map((p) => PlantWithSpecies(plant: p, species: speciesById[p.speciesId]!))
      .toList();
}
