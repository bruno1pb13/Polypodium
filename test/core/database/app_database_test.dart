import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('SpeciesTable allows null defaultIrrigationFrequencyDays', () async {
    final id = 'test-species';
    await db.into(db.speciesTable).insert(
          SpeciesTableCompanion.insert(
            id: id,
            scientificName: 'Test scientific',
            popularName: 'Test popular',
            defaultIrrigationFrequencyDays: const Value(null),
            recommendedSoilTypes: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    final species = await (db.select(db.speciesTable)..where((t) => t.id.equals(id))).getSingle();
    expect(species.defaultIrrigationFrequencyDays, isNull);
  });
}
