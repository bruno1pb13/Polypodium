import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../data_transfer/presentation/widgets/data_transfer_section.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../../../workspaces/presentation/screens/workspaces_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledNotifierProvider);
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final themeModeStr = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Geral'),
          SwitchListTile(
            title: const Text('Notificações de Rega'),
            subtitle: const Text('Habilitar ou desabilitar lembretes'),
            secondary: const Icon(Icons.notifications_outlined),
            value: notificationsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationsEnabledNotifierProvider.notifier)
                  .setEnabled(value);
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Aparência'),
          SwitchListTile(
            title: const Text('Transparência e Blur'),
            subtitle: const Text('Efeitos visuais em cartões e menus'),
            secondary: const Icon(Icons.blur_on),
            value: transparencyEnabled,
            onChanged: (value) {
              ref
                  .read(transparencyEnabledNotifierProvider.notifier)
                  .setEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modo Noturno'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'system',
                  icon: Icon(Icons.brightness_auto),
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: 'light',
                  icon: Icon(Icons.light_mode),
                  label: Text('Claro'),
                ),
                ButtonSegment(
                  value: 'dark',
                  icon: Icon(Icons.dark_mode),
                  label: Text('Escuro'),
                ),
              ],
              selected: {themeModeStr},
              onSelectionChanged: (newSelection) {
                ref
                    .read(themeModeNotifierProvider.notifier)
                    .setThemeMode(newSelection.first);
              },
              showSelectedIcon: false,
            ),
          ),
          const Divider(),
          _SectionHeader(title: 'Sincronização'),
          const _SyncSection(),
          const Divider(),
          _SectionHeader(title: 'Dados'),
          const DataTransferSection(),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'Polypodium',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2024 Polypodium Team',
            child: Text('Sobre o Aplicativo'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SyncSection extends ConsumerWidget {
  const _SyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final syncState = ref.watch(syncNotifierProvider);
    final pendingAsync = ref.watch(pendingSyncCountProvider);
    final isLoading = syncState.isLoading;
    final autoSyncEnabled = ref.watch(autoSyncEnabledNotifierProvider);

    final pendingText = pendingAsync.when(
      data: (n) => n == 0 ? 'Tudo sincronizado' : '$n evento(s) pendente(s)',
      loading: () => '...',
      error: (_, __) => '',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(workspace.type == WorkspaceType.local
              ? Icons.smartphone_outlined
              : (workspace.isLoggedIn
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined)),
          title: Text(workspace.name),
          subtitle: Text(
            workspace.type == WorkspaceType.local
                ? 'Workspace local — não sincroniza'
                : (workspace.isLoggedIn ? pendingText : 'Desconectado'),
          ),
          trailing: syncState.hasError
              ? IconButton(
                  icon: const Icon(Icons.error_outline, color: Colors.red),
                  tooltip: syncState.error.toString(),
                  onPressed: () =>
                      _showError(context, syncState.error.toString()),
                )
              : null,
        ),
        if (workspace.isLoggedIn)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () => ref.read(syncNotifierProvider.notifier).sync(),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync),
                label: Text(isLoading ? 'Sincronizando...' : 'Sincronizar Agora'),
              ),
            ),
          ),
        if (workspace.isLoggedIn)
          SwitchListTile(
            title: const Text('Sincronização automática'),
            subtitle: Text(autoSyncEnabled
                ? 'A cada 5 minutos (30 em economia de bateria no Android)'
                : 'Desativada — sincronize manualmente'),
            secondary: const Icon(Icons.autorenew),
            value: autoSyncEnabled,
            onChanged: (value) => ref
                .read(autoSyncEnabledNotifierProvider.notifier)
                .setEnabled(value),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkspacesScreen()),
              ),
              icon: const Icon(Icons.workspaces_outline),
              label: const Text('Gerenciar workspaces'),
            ),
          ),
        ),
      ],
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
