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
  Stream<List<SoilModel>> build() =>
      ref.watch(soilsRepositoryProvider).watchAll();

  Future<void> save(SoilModel soil) async {
    await ref.read(soilsRepositoryProvider).save(soil);
  }

  Future<void> delete(String soilId) async {
    await ref.read(soilsRepositoryProvider).delete(soilId);
  }
}
