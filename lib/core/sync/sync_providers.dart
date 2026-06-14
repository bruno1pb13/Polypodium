import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_provider.dart';
import '../storage/photo_storage.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import 'sync_service.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return SyncService(db, prefs, PhotoStorage());
}

@riverpod
Future<int> pendingSyncCount(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final pending = await db.syncQueueDao.getPending();
  return pending.length;
}

@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  AsyncValue<SyncResult?> build() => const AsyncValue.data(null);

  Future<void> sync() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(syncServiceProvider).sync(),
    );
    ref.invalidate(pendingSyncCountProvider);
  }

  Future<void> login(String serverUrl, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(syncServiceProvider).login(serverUrl, email, password);
      return null;
    });
  }

  Future<void> logout() async {
    await ref.read(syncServiceProvider).logout();
    state = const AsyncValue.data(null);
    ref.invalidate(pendingSyncCountProvider);
  }
}
