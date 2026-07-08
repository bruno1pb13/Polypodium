import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polypodium/features/species/data/external_species_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExternalSpeciesRepository', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('polypodium_test');
      dbFile = File(p.join(tempDir.path, 'external_flora.db'));
      
      // Create a dummy DB
      final db = sqlite3.open(dbFile.path);
      db.execute('CREATE TABLE external_species (popular_name TEXT, scientific_name TEXT)');
      db.execute("INSERT INTO external_species VALUES ('Rosa', 'Rosa gallica')");
      db.execute("INSERT INTO external_species VALUES ('Samambaia', 'Pteridium aquilinum')");
      db.close();
      
      // Make it > 1MB to skip asset copying in build()
      final sink = dbFile.openSync(mode: FileMode.append);
      sink.writeFromSync(Uint8List(1000001));
      sink.closeSync();

      // Mock path_provider
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      });

      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      // The OS may hold the sqlite3 file handle (or its -wal/-shm sidecar
      // files) open briefly after the connection closes. Retry a few times,
      // but don't fail the test over best-effort cleanup — a leftover temp
      // dir is recoverable manually (same tradeoff as
      // WorkspacesNotifier._deleteWorkspaceStorage).
      for (var attempt = 0; attempt < 6; attempt++) {
        try {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
          break;
        } catch (_) {
          if (attempt == 5) break;
          await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
        }
      }
    });

    test('search finds species by popular name', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger build
      await container.read(externalSpeciesRepositoryProvider.future);
      final repo = container.read(externalSpeciesRepositoryProvider.notifier);

      final results = await repo.search('Rosa');
      expect(results.length, 1);
      expect(results.first.popularName, 'Rosa');
      expect(results.first.scientificName, 'Rosa gallica');
    });

    test('search finds species by scientific name', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(externalSpeciesRepositoryProvider.future);
      final repo = container.read(externalSpeciesRepositoryProvider.notifier);

      final results = await repo.search('Pteridium');
      expect(results.length, 1);
      expect(results.first.scientificName, 'Pteridium aquilinum');
    });

    test('getSpeciesCount returns correct number of rows', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(externalSpeciesRepositoryProvider.future);
      final repo = container.read(externalSpeciesRepositoryProvider.notifier);

      final count = await repo.getSpeciesCount();
      expect(count, 2);
    });
  });
}
