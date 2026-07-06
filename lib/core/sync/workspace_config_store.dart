import '../../features/workspaces/domain/workspace_model.dart';

/// Decouples SyncService from where workspace configuration is actually
/// persisted, so the same SyncService code can operate on whichever
/// workspace it was constructed for.
abstract class WorkspaceConfigStore {
  Workspace get current;
  Future<void> save(Workspace updated);
}
