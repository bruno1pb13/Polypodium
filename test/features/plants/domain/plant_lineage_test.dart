import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/plants/domain/plant_lineage.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';

void main() {
  PlantModel plant(String id, [String? parent]) => PlantModel(
        id: id,
        speciesId: 's1',
        nickname: id,
        soilId: 'loamy',
        acquisitionDate: DateTime(2026),
        parentPlantId: parent,
        createdAt: DateTime(2026),
      );

  final plants = [
    plant('a'),
    plant('b', 'a'),
    plant('c', 'b'),
    plant('d', 'a'),
    plant('e'),
    plant('f', 'e'),
  ];

  test('cuttingsOf lists the direct children only', () {
    expect(cuttingsOf('a', plants).map((p) => p.id), ['b', 'd']);
    expect(cuttingsOf('c', plants), isEmpty);
  });

  test('lineageExclusions covers the plant and all its descendants', () {
    expect(lineageExclusions('a', plants), {'a', 'b', 'c', 'd'});
    expect(lineageExclusions('b', plants), {'b', 'c'});
    expect(lineageExclusions('f', plants), {'f'});
    // A new plant has nothing to exclude.
    expect(lineageExclusions(null, plants), isEmpty);
  });

  test('lineageExclusions terminates on an existing cycle', () {
    final cyclic = [plant('x', 'z'), plant('y', 'x'), plant('z', 'y')];
    expect(lineageExclusions('x', cyclic), {'x', 'y', 'z'});
  });
}
