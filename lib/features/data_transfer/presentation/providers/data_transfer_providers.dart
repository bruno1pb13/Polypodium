import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/storage/photo_storage_provider.dart';
import '../../../admin/presentation/providers/admin_providers.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../../data/data_export_service.dart';
import '../../data/data_import_service.dart';
import '../../domain/data_transfer_permission.dart';

part 'data_transfer_providers.g.dart';

@riverpod
DataExportService dataExportService(Ref ref) =>
    DataExportService(ref.watch(appDatabaseProvider));

@riverpod
DataImportService dataImportService(Ref ref) => DataImportService(
    ref.watch(appDatabaseProvider), ref.watch(photoStorageProvider));

/// Resolves whether the active workspace may export/import right now. The
/// server is asked fresh on every (re)build so a toggled admin setting takes
/// effect without re-login; invalidate this provider to re-check.
@riverpod
Future<DataTransferPermission> dataTransferPermission(Ref ref) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  if (workspace.type == WorkspaceType.local) {
    return DataTransferPermission.allowed;
  }
  if (!workspace.isLoggedIn) {
    return const DataTransferPermission(
      canExport: false,
      canImport: false,
      deniedReason: 'Conecte-se ao servidor para exportar ou importar.',
    );
  }
  try {
    final info = await ref.watch(adminClientProvider).me(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
        );
    return DataTransferPermission(
      canExport: info.canExportData,
      canImport: info.canImportData,
      deniedReason: 'Desativado pelo administrador do servidor.',
    );
  } catch (_) {
    // Offline or unreachable server: fall back to the cached role — admins
    // are never restricted, but a member's permission can't be verified.
    if (workspace.isServerAdmin) return DataTransferPermission.allowed;
    return const DataTransferPermission(
      canExport: false,
      canImport: false,
      deniedReason:
          'Não foi possível verificar a permissão com o servidor.',
    );
  }
}
