import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/workspaces/domain/workspace_paths.dart';
import '../../features/workspaces/presentation/providers/workspace_providers.dart';
import 'photo_storage.dart';

part 'photo_storage_provider.g.dart';

@Riverpod(keepAlive: true)
PhotoStorage photoStorage(Ref ref) {
  final workspace = ref.watch(activeWorkspaceProvider);
  return PhotoStorage(baseDirName: photoDirNameFor(workspace));
}
