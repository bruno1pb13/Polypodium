import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/soils_repository.dart';
import '../../domain/soil_model.dart';

part 'soils_providers.g.dart';

@Riverpod(keepAlive: true)
SoilsRepository soilsRepository(Ref ref) {
  return SoilsRepository(ref.watch(appDatabaseProvider));
}

@riverpod
class SoilsNotifier extends _$SoilsNotifier {
  @override
  Future<List<SoilModel>> build() =>
      ref.watch(soilsRepositoryProvider).getAll();

  Future<void> save(SoilModel soil) async {
    await ref.read(soilsRepositoryProvider).save(soil);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String soilId) async {
    await ref.read(soilsRepositoryProvider).delete(soilId);
    ref.invalidateSelf();
    await future;
  }
}
