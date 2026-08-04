import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/defensivos_repository.dart';
import '../../domain/defensivo_model.dart';

part 'defensivos_providers.g.dart';

@Riverpod(keepAlive: true)
DefensivosRepository defensivosRepository(Ref ref) {
  return DefensivosRepository(ref.watch(appDatabaseProvider));
}

@riverpod
class DefensivosNotifier extends _$DefensivosNotifier {
  @override
  Stream<List<DefensivoModel>> build() =>
      ref.watch(defensivosRepositoryProvider).watchAll();

  Future<void> save(DefensivoModel defensivo) async {
    await ref.read(defensivosRepositoryProvider).save(defensivo);
  }

  Future<void> delete(String defensivoId) async {
    await ref.read(defensivosRepositoryProvider).delete(defensivoId);
  }
}
