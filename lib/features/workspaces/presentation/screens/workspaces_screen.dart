import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../plants/presentation/screens/home_screen.dart';
import '../../data/workspace_auth_client.dart';
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
            ),
          if (remotes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Nenhum workspace remoto ainda. Adicione um para sincronizar '
                'estes dados com um servidor.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRemote(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar workspace remoto'),
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
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => WorkspaceLoginDialog(
        title: 'Adicionar workspace remoto',
        checkServer: const WorkspaceAuthClient().checkServer,
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
      ),
    );
    if (created == true && context.mounted) _goHome(context);
  }

  Future<void> _reconnect(
      BuildContext context, WidgetRef ref, Workspace ws) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => WorkspaceLoginDialog(
        title: 'Reconectar "${ws.name}"',
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
        title: const Text('Desconectar'),
        content: const Text(
          'Os dados deste workspace continuam neste dispositivo. '
          'Para sincronizar novamente, entre com sua conta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desconectar'),
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
        title: Text('Excluir "${ws.name}"?'),
        content: const Text(
          'Os dados deste workspace serão apagados deste dispositivo. '
          'Isso não afeta a conta nem os dados no servidor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(workspacesNotifierProvider.notifier).removeRemote(ws.id);
    }
  }

  Future<void> _rename(
      BuildContext context, WidgetRef ref, Workspace ws) async {
    final controller = TextEditingController(text: ws.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renomear workspace'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar'),
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
  });

  final Workspace workspace;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onReconnect;
  final VoidCallback? onDisconnect;
  final VoidCallback? onDelete;

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
            const Chip(
              label: Text('Local'),
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
          ? 'Dados só neste dispositivo'
          : (workspace.isLoggedIn
              ? (workspace.userEmail ?? 'Conectado')
              : 'Desconectado')),
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
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'rename', child: Text('Renomear')),
                if (onReconnect != null)
                  const PopupMenuItem(
                      value: 'reconnect', child: Text('Reconectar')),
                if (onDisconnect != null)
                  const PopupMenuItem(
                      value: 'disconnect', child: Text('Desconectar')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
            ),
    );
  }
}
