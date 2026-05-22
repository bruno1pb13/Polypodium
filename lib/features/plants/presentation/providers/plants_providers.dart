import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/plants_repository.dart';
import '../../domain/plant_model.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
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
  // Watch all futures at once to keep them alive and potentially run in parallel
  final plantsFuture = ref.watch(plantsNotifierProvider.future);
  final speciesFuture = ref.watch(speciesNotifierProvider.future);
  final locationsFuture = ref.watch(locationsNotifierProvider.future);

  final plants = await plantsFuture;
  final species = await speciesFuture;
  final locations = await locationsFuture;

  final speciesById = {for (final s in species) s.id: s};
  final locationsById = {for (final l in locations) l.id: l};

  return plants
      .where((p) => speciesById.containsKey(p.speciesId))
      .map((p) => PlantWithSpecies(
            plant: p,
            species: speciesById[p.speciesId]!,
            location: p.locationId != null ? locationsById[p.locationId] : null,
          ))
      .toList();
}
