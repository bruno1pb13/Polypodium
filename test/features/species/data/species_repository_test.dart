import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/species/data/species_repository.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

void main() {
  late AppDatabase db;
  late SpeciesRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'device-a');
    repo = SpeciesRepository(db);
  });

  tearDown(() => db.close());

  final species = SpeciesModel(
    id: 's1',
    scientificName: 'Dieffenbachia seguine',
    popularName: 'Comigo-ninguém-pode',
    defaultIrrigationFrequencyDays: 5,
    recommendedSoilIds: const ['loamy'],
    light: LightRequirement.partialShade,
    humidity: HumidityLevel.high,
    petToxicity: PetToxicity.toxic,
    floweringMonths: const {12, 1},
    careNotes: 'Seiva irritante',
    createdAt: DateTime(2026, 1, 1),
  );

  test('the care sheet round-trips through the repository', () async {
    await repo.save(species);

    final loaded = await repo.getById('s1');
    expect(loaded!.light, LightRequirement.partialShade);
    expect(loaded.humidity, HumidityLevel.high);
    expect(loaded.petToxicity, PetToxicity.toxic);
    expect(loaded.floweringMonths, {1, 12});
    expect(loaded.careNotes, 'Seiva irritante');
    expect(loaded.hasCareInfo, isTrue);
    expect(loaded.localRev, greaterThan(0));
    expect((await db.speciesDao.getById('s1'))!.deviceId, 'device-a');
  });

  test('clearing the care sheet persists the empty values', () async {
    await repo.save(species);
    await repo.save(species.copyWith(
      light: null,
      humidity: null,
      petToxicity: PetToxicity.unknown,
      floweringMonths: const {},
      careNotes: null,
    ));

    final loaded = await repo.getById('s1');
    expect(loaded!.light, isNull);
    expect(loaded.humidity, isNull);
    expect(loaded.petToxicity, PetToxicity.unknown);
    expect(loaded.floweringMonths, isEmpty);
    expect(loaded.careNotes, isNull);
    expect(loaded.hasCareInfo, isFalse);
  });

  test('copyWith keeps the care sheet when not overridden', () {
    final renamed = species.copyWith(popularName: 'Aningapara');
    expect(renamed.light, LightRequirement.partialShade);
    expect(renamed.humidity, HumidityLevel.high);
    expect(renamed.petToxicity, PetToxicity.toxic);
    expect(renamed.floweringMonths, {1, 12});
    expect(renamed.careNotes, 'Seiva irritante');
  });
}
