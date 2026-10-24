import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/links/external_links.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/updates/distribution_channel.dart';
import '../../../../core/updates/update_controller.dart';
import '../../../data_transfer/presentation/widgets/data_transfer_section.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../../../workspaces/presentation/screens/workspaces_screen.dart';
import '../providers/settings_providers.dart';

/// Watering reminders: whether they're on and at what time of day. The
/// weather that moves their dates has a category of its own
/// (WeatherSettings).
class RemindersSettings extends ConsumerWidget {
  const RemindersSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledNotifierProvider);
    final notificationTime = ref.watch(notificationTimeNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        ListTile(
          enabled: notificationsEnabled,
          leading: const Icon(Icons.schedule_outlined),
          title: Text(context.l10n.notificationTime),
          subtitle: Text(context.l10n.notificationTimeSubtitle),
          trailing: Text(
            notificationTime.format(context),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: notificationTime,
            );
            if (picked != null) {
              ref
                  .read(notificationTimeNotifierProvider.notifier)
                  .setTime(picked);
            }
          },
        ),
      ],
    );
  }
}

/// Transparency and the light/dark theme.
class AppearanceSettings extends ConsumerWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final themeModeStr = ref.watch(themeModeNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        LayoutBuilder(
          builder: (context, constraints) {
            final themeSelector = SegmentedButton<String>(
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
            );
            // Em telas estreitas o SegmentedButton como trailing esmaga o
            // título; nesse caso ele desce para uma linha própria.
            if (constraints.maxWidth < 480) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: Text(context.l10n.darkMode),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: themeSelector,
                  ),
                ],
              );
            }
            return ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(context.l10n.darkMode),
              trailing: themeSelector,
            );
          },
        ),
      ],
    );
  }
}

/// The active workspace's sync state and controls, and the way to the
/// workspaces screen.
class SyncSettings extends ConsumerWidget {
  const SyncSettings({super.key});

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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
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
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(context.l10n.viewDocumentation),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => openExternalLink(
              context, ExternalLinks.serverDocs(context.l10n.localeName)),
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

/// Export and import of the whole garden.
class DataSettings extends StatelessWidget {
  const DataSettings({super.key});

  @override
  Widget build(BuildContext context) => const DataTransferSection();
}

/// Version, update check, the project's pages and the licenses.
class AboutSettings extends ConsumerWidget {
  const AboutSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value;
    final locale = context.l10n.localeName;

    Widget link(IconData icon, String title, Uri url) => ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => openExternalLink(context, url),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Image.asset('assets/images/logo.png',
              width: 40, height: 40, excludeFromSemantics: true),
          title: const Text('Polypodium'),
          subtitle: version == null
              ? null
              : Text(context.l10n.updateCurrentVersion(version)),
        ),
        const _UpdateTile(),
        const Divider(),
        link(Icons.public, context.l10n.appWebsite,
            ExternalLinks.website(locale)),
        link(Icons.menu_book_outlined, context.l10n.viewDocumentation,
            ExternalLinks.serverDocs(locale)),
        link(Icons.privacy_tip_outlined, context.l10n.privacyPolicy,
            ExternalLinks.privacyPolicy(locale)),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(context.l10n.openSourceLicenses),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Polypodium',
            applicationVersion: version ?? '',
            applicationLegalese: '© 2024 Polypodium Team',
          ),
        ),
      ],
    );
  }
}

/// Manual update check, for builds that look for updates themselves (Google
/// Play and GitHub). Microsoft Store and package-manager installs are kept
/// up to date by the store, so the tile is hidden there.
class _UpdateTile extends ConsumerStatefulWidget {
  const _UpdateTile();

  @override
  ConsumerState<_UpdateTile> createState() => _UpdateTileState();
}

class _UpdateTileState extends ConsumerState<_UpdateTile> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    final result =
        await ref.read(updateControllerProvider.notifier).checkNow();
    if (!mounted) return;
    setState(() => _checking = false);
    final message = switch (result) {
      UpdateCheckResult.available => context.l10n.updateFound,
      UpdateCheckResult.upToDate => context.l10n.updateUpToDate,
      UpdateCheckResult.failed ||
      UpdateCheckResult.unsupported =>
        context.l10n.updateCheckFailed,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final channel = ref.watch(distributionChannelProvider);
    if (channel != DistributionChannel.playStore &&
        channel != DistributionChannel.github) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(Icons.system_update_outlined),
      title: Text(context.l10n.updateCheck),
      trailing: _checking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _checking ? null : _check,
    );
  }
}
