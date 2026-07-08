import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/locations_repository.dart';
import '../../domain/location_model.dart';

import '../../../../core/sync/sync_providers.dart';

part 'locations_providers.g.dart';

@Riverpod(keepAlive: true)
LocationsRepository locationsRepository(Ref ref) {
  return LocationsRepository(ref.watch(appDatabaseProvider));
}

@riverpod
class LocationsNotifier extends _$LocationsNotifier {
  @override
  Stream<List<LocationModel>> build() =>
      ref.watch(locationsRepositoryProvider).watchAll();

  Future<void> save(LocationModel location) async {
    await ref.read(locationsRepositoryProvider).save(location);

    // Trigger immediate sync if logged in
    try {
      final syncService = ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }

  Future<void> delete(String locationId) async {
    await ref.read(locationsRepositoryProvider).delete(locationId);

    // Trigger immediate sync if logged in
    try {
      final syncService = ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }
}
