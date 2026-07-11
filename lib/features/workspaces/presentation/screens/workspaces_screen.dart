import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/storage/photo_storage_provider.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../admin/data/admin_client.dart';
import '../../../admin/presentation/screens/server_admin_screen.dart';
import '../../../plants/presentation/screens/home_screen.dart';
import '../../data/workspace_auth_client.dart';
import '../../data/workspace_migration_service.dart';
import '../../domain/workspace_model.dart';
import '../providers/workspace_providers.dart';
import '../widgets/workspace_login_dialog.dart';

class WorkspacesScreen extends ConsumerWidget {
  const WorkspacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspacesNotifierProvider);
    final activeId = ref.watch(activeWorkspaceIdNotifierProvider);

    final local =
        workspaces.firstWhere((w) => w.type == WorkspaceType.local);
    final remotes =
        workspaces.where((w) => w.type == WorkspaceType.remote).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Workspaces')),
      body: ListView(
        children: [
          _WorkspaceTile(
            workspace: local,
            isActive: activeId == local.id,
            onTap: () => _activate(context, ref, local.id),
          ),
          const Divider(),
          for (final ws in remotes)
            _WorkspaceTile(
              workspace: ws,
              isActive: activeId == ws.id,
              onTap: () => _activate(context, ref, ws.id),
              onRename: () => _rename(context, ref, ws),
              onReconnect:
                  !ws.isLoggedIn ? () => _reconnect(context, ref, ws) : null,
              onDisconnect:
                  ws.isLoggedIn ? () => _disconnect(context, ref, ws) : null,
              onDelete: () => _delete(context, ref, ws),
              onAdminPanel:
                  ws.isServerAdmin ? () => _openAdmin(context, ref, ws) : null,
            ),
          if (remotes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.noRemoteWorkspaces,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRemote(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addRemoteWorkspace),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _activate(
      BuildContext context, WidgetRef ref, String id) async {
    if (ref.read(activeWorkspaceIdNotifierProvider) == id) return;
    await ref.read(activeWorkspaceIdNotifierProvider.notifier).setActive(id);
    if (context.mounted) _goHome(context);
  }

  Future<void> _addRemote(BuildContext context, WidgetRef ref) async {
    const authClient = WorkspaceAuthClient();
    const migrationService = WorkspaceMigrationService();

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => WorkspaceLoginDialog(
        title: context.l10n.addRemoteWorkspace,
        checkServer: authClient.checkServer,
        checkHasUsers: authClient.hasUsers,
        onSubmit: (serverUrl, email, password) async {
          final ws = await ref
              .read(workspacesNotifierProvider.notifier)
              .createAndLoginRemote(
                serverUrl: serverUrl,
                email: email,
                password: password,
              );
          await ref
              .read(activeWorkspaceIdNotifierProvider.notifier)
              .setActive(ws.id);
        },
        onRegister: (serverUrl, workspaceName, email, password) async {
          final ws = await ref
              .read(workspacesNotifierProvider.notifier)
              .createAndRegisterRemote(
                serverUrl: serverUrl,
                name: workspaceName,
                email: email,
                password: password,
              );
          await ref
              .read(activeWorkspaceIdNotifierProvider.notifier)
              .setActive(ws.id);
        },
        hasLocalDataToMigrate: () => migrationService.hasPendingLocalData(
          ref.read(workspacesNotifierProvider.notifier).getById(
                Workspace.localId,
              ),
        ),
        onMigrate: () async {
          final local = ref
              .read(workspacesNotifierProvider.notifier)
              .getById(Workspace.localId);
          await migrationService.migrateLocalInto(
            local: local,
            targetDb: ref.read(appDatabaseProvider),
            targetPhotos: ref.read(photoStorageProvider),
          );
          await ref.read(syncServiceProvider).sync();
        },
      ),
    );
    if (created == true && context.mounted) _goHome(context);
  }

  Future<void> _reconnect(
      BuildContext context, WidgetRef ref, Workspace ws) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => WorkspaceLoginDialog(
        title: context.l10n.reconnectWorkspace(ws.name),
        serverUrlEditable: false,
        initialServerUrl: ws.serverUrl,
        initialEmail: ws.userEmail,
        checkServer: const WorkspaceAuthClient().checkServer,
        onSubmit: (serverUrl, email, password) => ref
            .read(workspacesNotifierProvider.notifier)
            .reconnectRemote(ws.id, password),
      ),
    );
  }

  Future<void> _disconnect(
      BuildContext context, WidgetRef ref, Workspace ws) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.disconnect),
        content: Text(ctx.l10n.disconnectBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.disconnect),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(workspacesNotifierProvider.notifier).logoutRemote(ws.id);
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Workspace ws) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deleteWorkspaceTitle(ws.name)),
        content: Text(ctx.l10n.deleteWorkspaceBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.deleteAction,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(workspacesNotifierProvider.notifier).removeRemote(ws.id);
    }
  }

  /// Re-checks the account's role against the server before opening the
  /// admin panel -- the cached [Workspace.role] may be stale if another
  /// admin demoted this account since the last login.
  Future<void> _openAdmin(
      BuildContext context, WidgetRef ref, Workspace ws) async {
    String role;
    try {
      final info = await const AdminClient().me(
        serverUrl: ws.serverUrl!,
        token: ws.token!,
      );
      role = info.role;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
      }
      return;
    }

    final updated = ws.copyWith(role: role);
    await ref.read(workspacesNotifierProvider.notifier).upsert(updated);

    if (role != 'admin') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.adminPermissionLost),
        ));
      }
      return;
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ServerAdminScreen(workspace: updated)),
      );
    }
  }

  Future<void> _rename(
      BuildContext context, WidgetRef ref, Workspace ws) async {
    final controller = TextEditingController(text: ws.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.renameWorkspace),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(ctx.l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null && newName.isNotEmpty) {
      await ref.read(workspacesNotifierProvider.notifier).rename(ws.id, newName);
    }
  }
}

class _WorkspaceTile extends StatelessWidget {
  const _WorkspaceTile({
    required this.workspace,
    required this.isActive,
    required this.onTap,
    this.onRename,
    this.onReconnect,
    this.onDisconnect,
    this.onDelete,
    this.onAdminPanel,
  });

  final Workspace workspace;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onReconnect;
  final VoidCallback? onDisconnect;
  final VoidCallback? onDelete;
  final VoidCallback? onAdminPanel;

  bool get _isLocal => workspace.type == WorkspaceType.local;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_isLocal
          ? Icons.smartphone_outlined
          : (workspace.isLoggedIn
              ? Icons.cloud_done_outlined
              : Icons.cloud_off_outlined)),
      title: Row(
        children: [
          Flexible(
              child: Text(workspace.name, overflow: TextOverflow.ellipsis)),
          if (_isLocal) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(context.l10n.localChip),
              visualDensity: VisualDensity.compact,
            ),
          ],
          if (isActive) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle,
                size: 18, color: Theme.of(context).colorScheme.primary),
          ],
        ],
      ),
      subtitle: Text(_isLocal
          ? context.l10n.dataOnlyOnDevice
          : (workspace.isLoggedIn
              ? (workspace.userEmail ?? context.l10n.connected)
              : context.l10n.disconnected)),
      selected: isActive,
      onTap: onTap,
      trailing: _isLocal
          ? null
          : PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'rename':
                    onRename?.call();
                  case 'reconnect':
                    onReconnect?.call();
                  case 'disconnect':
                    onDisconnect?.call();
                  case 'delete':
                    onDelete?.call();
                  case 'admin':
                    onAdminPanel?.call();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 'rename', child: Text(context.l10n.rename)),
                if (onReconnect != null)
                  PopupMenuItem(
                      value: 'reconnect',
                      child: Text(context.l10n.reconnect)),
                if (onDisconnect != null)
                  PopupMenuItem(
                      value: 'disconnect',
                      child: Text(context.l10n.disconnect)),
                if (onAdminPanel != null) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                      value: 'admin',
                      child: Text(context.l10n.serverAdministration)),
                ],
                const PopupMenuDivider(),
                PopupMenuItem(
                    value: 'delete', child: Text(context.l10n.deleteAction)),
              ],
            ),
    );
  }
}
