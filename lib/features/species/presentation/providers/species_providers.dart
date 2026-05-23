import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
}
