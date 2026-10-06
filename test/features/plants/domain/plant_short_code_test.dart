import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';

void main() {
  test('is the first 6 characters of the id, uppercase', () {
    expect(plantShortCode('3f9a1c2e-7b4d-4c1a-9e2f-0123456789ab'), '3F9A1C');
    expect(plantShortCode('3f9a-1c2e'), '3F9A1C');
    expect(plantShortCode('p1'), 'P1');
  });

  test('matches queries of 4+ characters at the start, # optional', () {
    expect(matchesPlantShortCode('3f9a', '3F9A1C'), isTrue);
    expect(matchesPlantShortCode('3f9a1c', '3F9A1C'), isTrue);
    expect(matchesPlantShortCode('#3f9a1c', '3F9A1C'), isTrue);
    expect(matchesPlantShortCode(' 3f9a1c ', '3F9A1C'), isTrue);
    expect(matchesPlantShortCode('3f9', '3F9A1C'), isFalse);
    expect(matchesPlantShortCode('9a1c', '3F9A1C'), isFalse);
    expect(matchesPlantShortCode('3f9a1d', '3F9A1C'), isFalse);
  });
}
