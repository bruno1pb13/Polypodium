import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/database/database_provider.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SpeciesNotifier', () {
    test('getOrCreateFromExternal returns existing species if scientific name matches', () async {
      final existing = SpeciesModel(
        id: 'existing-id',
        scientificName: 'Rosa gallica',
        popularName: 'Red Rose',
        defaultIrrigationFrequencyDays: 3,
        recommendedSoilIds: [],
        createdAt: DateTime.now(),
      );
      
      await container.read(speciesNotifierProvider.notifier).save(existing);
      
      final resultId = await container.read(speciesNotifierProvider.notifier).getOrCreateFromExternal(
        popularName: 'Old Rose', // Different popular name
        scientificName: 'Rosa gallica', // Same scientific name
      );
      
      expect(resultId, 'existing-id');
      
      final all = await container.read(speciesNotifierProvider.future);
      expect(all.length, 1);
    });

    test('getOrCreateFromExternal creates new species if no match found', () async {
      final resultId = await container.read(speciesNotifierProvider.notifier).getOrCreateFromExternal(
        popularName: 'New Plant',
        scientificName: 'Planta nova',
      );
      
      expect(resultId, isNotNull);
      
      // Wait for the stream to emit the new data. 
      // We might need to give it a moment for the DB stream to fire.
      await Future.delayed(const Duration(milliseconds: 100));
      final all = await container.read(speciesNotifierProvider.future);
      expect(all.length, 1);
      expect(all.first.id, resultId);
      expect(all.first.scientificName, 'Planta nova');
      expect(all.first.popularName, 'New Plant');
      expect(all.first.defaultIrrigationFrequencyDays, isNull);
    });
  });
}
