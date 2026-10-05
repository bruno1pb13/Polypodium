import 'plant_model.dart';

/// Plants whose parent is [plantId].
List<PlantModel> cuttingsOf(String plantId, Iterable<PlantModel> plants) => [
      for (final p in plants)
        if (p.parentPlantId == plantId) p
    ];

/// Ids that can't be the parent of [plantId]: the plant itself and every
/// plant descending from it, since picking one would close a cycle.
///
/// Walks [plants] only, so a link through a plant missing from it (deleted)
/// isn't followed; a cycle can also arrive by sync from two devices. Code
/// following parent links must therefore stop at plants it already visited.
Set<String> lineageExclusions(String? plantId, Iterable<PlantModel> plants) {
  if (plantId == null) return const {};
  final childrenByParent = <String, List<String>>{};
  for (final p in plants) {
    final parent = p.parentPlantId;
    if (parent != null) (childrenByParent[parent] ??= []).add(p.id);
  }
  final excluded = <String>{plantId};
  final pending = [plantId];
  while (pending.isNotEmpty) {
    for (final child in childrenByParent[pending.removeLast()] ?? const []) {
      if (excluded.add(child)) pending.add(child);
    }
  }
  return excluded;
}
