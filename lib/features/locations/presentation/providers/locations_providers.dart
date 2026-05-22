import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/locations_repository.dart';
import '../../domain/location_model.dart';

part 'locations_providers.g.dart';

@Riverpod(keepAlive: true)
LocationsRepository locationsRepository(LocationsRepositoryRef ref) {
  return LocationsRepository(ref.watch(appDatabaseProvider));
}

@riverpod
class LocationsNotifier extends _$LocationsNotifier {
  @override
  Future<List<LocationModel>> build() =>
      ref.watch(locationsRepositoryProvider).getAll();

  Future<void> save(LocationModel location) async {
    await ref.read(locationsRepositoryProvider).save(location);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String locationId) async {
    await ref.read(locationsRepositoryProvider).delete(locationId);
    ref.invalidateSelf();
    await future;
  }
}
