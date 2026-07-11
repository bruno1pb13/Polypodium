import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
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
        title: Text(context.l10n.navSettings),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: context.l10n.settingsGeneral),
          SwitchListTile(
            title: Text(context.l10n.wateringNotifications),
            subtitle: Text(context.l10n.wateringNotificationsSubtitle),
            secondary: const Icon(Icons.notifications_outlined),
            value: notificationsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationsEnabledNotifierProvider.notifier)
                  .setEnabled(value);
            },
          ),
          const Divider(),
          _SectionHeader(title: context.l10n.settingsAppearance),
          SwitchListTile(
            title: Text(context.l10n.transparencyAndBlur),
            subtitle: Text(context.l10n.transparencyAndBlurSubtitle),
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
            title: Text(context.l10n.darkMode),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'system',
                  icon: const Icon(Icons.brightness_auto),
                  label: Text(context.l10n.themeAuto),
                ),
                ButtonSegment(
                  value: 'light',
                  icon: const Icon(Icons.light_mode),
                  label: Text(context.l10n.themeLight),
                ),
                ButtonSegment(
                  value: 'dark',
                  icon: const Icon(Icons.dark_mode),
                  label: Text(context.l10n.themeDark),
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
          _SectionHeader(title: context.l10n.settingsSync),
          const _SyncSection(),
          const Divider(),
          _SectionHeader(title: context.l10n.settingsData),
          const DataTransferSection(),
          const Divider(),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: 'Polypodium',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2024 Polypodium Team',
            child: Text(context.l10n.aboutApp),
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
      data: (n) => n == 0
          ? context.l10n.allSynced
          : context.l10n.pendingEventsCount(n),
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
                ? context.l10n.localWorkspaceNoSync
                : (workspace.isLoggedIn
                    ? pendingText
                    : context.l10n.disconnected),
          ),
          trailing: syncState.hasError
              ? IconButton(
                  icon: const Icon(Icons.error_outline, color: Colors.red),
                  tooltip:
                      localizedErrorMessage(syncState.error!, context.l10n),
                  onPressed: () => _showError(context,
                      localizedErrorMessage(syncState.error!, context.l10n)),
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
                label:
                    Text(isLoading ? context.l10n.syncing : context.l10n.syncNow),
              ),
            ),
          ),
        if (workspace.isLoggedIn)
          SwitchListTile(
            title: Text(context.l10n.autoSync),
            subtitle: Text(autoSyncEnabled
                ? context.l10n.autoSyncOnSubtitle
                : context.l10n.autoSyncOffSubtitle),
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
              label: Text(context.l10n.manageWorkspaces),
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
