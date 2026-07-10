import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../workspaces/domain/workspace_model.dart';
import '../../domain/server_status.dart';
import '../../domain/server_user.dart';
import '../providers/admin_providers.dart';

class ServerAdminScreen extends ConsumerWidget {
  const ServerAdminScreen({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(serverStatusProvider(workspace));
    final usersAsync = ref.watch(serverUsersNotifierProvider(workspace));

    return Scaffold(
      appBar: AppBar(title: const Text('Administração do servidor')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(serverStatusProvider(workspace));
          ref.invalidate(serverDataSettingsNotifierProvider(workspace));
          ref.invalidate(serverUsersNotifierProvider(workspace));
        },
        child: ListView(
          children: [
            _StatusCard(statusAsync: statusAsync),
            _DataSettingsCard(workspace: workspace),
            const Divider(height: 1),
            usersAsync.when(
              data: (users) => Column(
                children: [
                  for (final user in users)
                    _UserTile(
                      user: user,
                      isSelf: user.email == workspace.userEmail,
                      onSetRole: (role) => _confirmAndRun(
                        context,
                        title:
                            role == 'admin' ? 'Promover a admin?' : 'Rebaixar para membro?',
                        message: role == 'admin'
                            ? '${user.email} passará a ter acesso total de administração do servidor.'
                            : '${user.email} perderá o acesso de administração do servidor.',
                        confirmLabel: role == 'admin' ? 'Promover' : 'Rebaixar',
                        destructive: role != 'admin',
                        action: () => ref
                            .read(serverUsersNotifierProvider(workspace).notifier)
                            .setRole(user.id, role),
                      ),
                      onSetDisabled: (disabled) => _confirmAndRun(
                        context,
                        title: disabled ? 'Desativar conta?' : 'Reativar conta?',
                        message: disabled
                            ? '${user.email} não conseguirá mais entrar. Os dados são mantidos.'
                            : '${user.email} poderá entrar novamente.',
                        confirmLabel: disabled ? 'Desativar' : 'Reativar',
                        destructive: disabled,
                        action: () => ref
                            .read(serverUsersNotifierProvider(workspace).notifier)
                            .setDisabled(user.id, disabled),
                      ),
                    ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar usuários: $e'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addUser(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Adicionar usuário'),
      ),
    );
  }

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required bool destructive,
    required Future<void> Function() action,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: destructive
                  ? TextStyle(color: Theme.of(ctx).colorScheme.error)
                  : null,
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _addUser(BuildContext context, WidgetRef ref) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    final email = emailController.text.trim();
    final password = passwordController.text;
    emailController.dispose();
    passwordController.dispose();

    if (created != true || email.isEmpty || password.isEmpty) return;
    try {
      await ref
          .read(serverUsersNotifierProvider(workspace).notifier)
          .createUser(email, password);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.statusAsync});

  final AsyncValue<ServerStatus> statusAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statusAsync.when(
          data: (status) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Servidor', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Uptime: ${_formatUptime(status.uptimeSeconds)}'),
              Text('Versão: ${status.version}'),
              Text('Usuários: ${status.userCount}'),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro ao carregar status: $e'),
        ),
      ),
    );
  }

  String _formatUptime(int seconds) {
    final d = Duration(seconds: seconds);
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _DataSettingsCard extends ConsumerWidget {
  const _DataSettingsCard({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync =
        ref.watch(serverDataSettingsNotifierProvider(workspace));

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: settingsAsync.when(
          data: (settings) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text('Permissões de membros',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              SwitchListTile(
                title: const Text('Exportar dados'),
                subtitle:
                    const Text('Membros podem exportar os próprios dados'),
                value: settings.allowMemberExport,
                onChanged: (value) => _update(
                    context,
                    ref
                        .read(serverDataSettingsNotifierProvider(workspace)
                            .notifier)
                        .setAllowMemberExport(value)),
              ),
              SwitchListTile(
                title: const Text('Importar dados'),
                subtitle:
                    const Text('Membros podem importar dados de um backup'),
                value: settings.allowMemberImport,
                onChanged: (value) => _update(
                    context,
                    ref
                        .read(serverDataSettingsNotifierProvider(workspace)
                            .notifier)
                        .setAllowMemberImport(value)),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro ao carregar permissões: $e'),
          ),
        ),
      ),
    );
  }

  Future<void> _update(BuildContext context, Future<void> action) async {
    try {
      await action;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSelf,
    required this.onSetRole,
    required this.onSetDisabled,
  });

  final ServerUser user;
  final bool isSelf;
  final void Function(String role) onSetRole;
  final void Function(bool disabled) onSetDisabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(user.isAdmin
          ? Icons.admin_panel_settings_outlined
          : Icons.person_outline),
      title: Row(
        children: [
          Flexible(child: Text(user.email, overflow: TextOverflow.ellipsis)),
          if (isSelf) ...[
            const SizedBox(width: 8),
            const Chip(
              label: Text('Você'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
      subtitle: Text([
        user.isAdmin ? 'Admin' : 'Membro',
        if (user.disabled) 'Desativado',
      ].join(' · ')),
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          switch (action) {
            case 'promote':
              onSetRole('admin');
            case 'demote':
              onSetRole('member');
            case 'disable':
              onSetDisabled(true);
            case 'enable':
              onSetDisabled(false);
          }
        },
        itemBuilder: (context) => [
          if (!user.isAdmin)
            const PopupMenuItem(
                value: 'promote', child: Text('Promover a admin')),
          if (user.isAdmin)
            const PopupMenuItem(
                value: 'demote', child: Text('Rebaixar para membro')),
          const PopupMenuDivider(),
          if (!user.disabled)
            const PopupMenuItem(
                value: 'disable', child: Text('Desativar conta')),
          if (user.disabled)
            const PopupMenuItem(
                value: 'enable', child: Text('Reativar conta')),
        ],
      ),
    );
  }
}
