import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/species_repository.dart';
import '../../domain/species_model.dart';

part 'species_providers.g.dart';

@Riverpod(keepAlive: true)
SpeciesRepository speciesRepository(Ref ref) {
  return SpeciesRepository(ref.watch(appDatabaseProvider));
}

@riverpod
class SpeciesNotifier extends _$SpeciesNotifier {
  @override
  Future<List<SpeciesModel>> build() =>
      ref.watch(speciesRepositoryProvider).getAll();

  Future<void> save(SpeciesModel species) async {
    await ref.read(speciesRepositoryProvider).save(species);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    await ref.read(speciesRepositoryProvider).delete(id);
    ref.invalidateSelf();
    await future;
  }

  Future<String> getOrCreateFromExternal({
    required String popularName,
    required String scientificName,
  }) async {
    final existing = await future;
    
    // Check if scientific name already exists in local DB
    final match = existing.cast<SpeciesModel?>().firstWhere(
      (s) => s?.scientificName.toLowerCase() == scientificName.toLowerCase(),
      orElse: () => null,
    );

    if (match != null) return match.id;

    // If not, create a new local species
    final newSpecies = SpeciesModel(
      id: const Uuid().v4(),
      popularName: popularName,
      scientificName: scientificName,
      defaultIrrigationFrequencyDays: null,
      recommendedSoilTypes: [],
      createdAt: DateTime.now(),
    );

    await save(newSpecies);
    return newSpecies.id;
  }
}
