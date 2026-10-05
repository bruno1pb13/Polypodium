import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../defensivos/presentation/providers/defensivos_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../domain/carencia.dart';
import 'entries_providers.dart';

/// Today's carência of a plant, following its entries and the defensivos
/// catalog as they change. Null when the plant can be harvested.
final plantCarenciaProvider =
    Provider.autoDispose.family<CarenciaStatus?, String>((ref, plantId) {
  final entries = ref.watch(entriesNotifierProvider(plantId)).value;
  if (entries == null) return null;
  final defensivos = ref.watch(defensivosNotifierProvider).value ?? const [];
  return carenciaOn(
      DateTime.now(), entries, carenciaDaysByDefensivo(defensivos));
});

typedef PlantCarencia = ({
  String plantId,
  String plantName,
  CarenciaStatus status,
});

final carenciaCheckerProvider =
    Provider<CarenciaChecker>((ref) => CarenciaChecker(ref));

/// One-off carência lookups, for checks made when saving an entry.
class CarenciaChecker {
  CarenciaChecker(this._ref);

  final Ref _ref;

  /// The plants among [plantIds] that are in carência on [day], in order.
  Future<List<PlantCarencia>> plantsInCarencia(
      List<String> plantIds, DateTime day) async {
    final catalog = carenciaDaysByDefensivo(
        await _ref.read(defensivosRepositoryProvider).getAll());
    final entriesRepo = _ref.read(entriesRepositoryProvider);
    final plantsRepo = _ref.read(plantsRepositoryProvider);
    final result = <PlantCarencia>[];
    for (final plantId in plantIds) {
      final status =
          carenciaOn(day, await entriesRepo.getByPlant(plantId), catalog);
      if (status == null) continue;
      final plant = await plantsRepo.getById(plantId);
      result.add((
        plantId: plantId,
        plantName: plant?.nickname ?? '',
        status: status,
      ));
    }
    return result;
  }
}
