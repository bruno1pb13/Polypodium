import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/workspaces/domain/workspace_paths.dart';
import '../../features/workspaces/presentation/providers/workspace_providers.dart';
import 'app_database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final workspace = ref.watch(activeWorkspaceProvider);
  final db = AppDatabase(fileName: dbFileNameFor(workspace));
  ref.onDispose(db.close);
  return db;
}
