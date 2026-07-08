import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_shell.dart';
import '../../domain/workspace_model.dart';
import '../providers/workspace_providers.dart';
import '../screens/workspaces_screen.dart';

const String _manageAction = '__manage__';

/// Notion-style workspace switcher: shows the active workspace and, on tap,
/// opens a dropdown listing every workspace plus a link to the full
/// management screen (rename/add/remove). Meant to sit at the very top of
/// the navigation surface (drawer header or sidebar header), replacing the
/// old "Workspaces" menu entry.
class WorkspaceSelector extends ConsumerWidget {
  const WorkspaceSelector({super.key, this.dark = false});

  /// Whether this sits over a dark/glass background (drawer) rather than a
  /// themed surface (wide sidebar), which needs light text/icons regardless
  /// of the app's light/dark theme.
  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspacesNotifierProvider);
    final active = ref.watch(activeWorkspaceProvider);
    final cs = Theme.of(context).colorScheme;

    final textColor = dark ? Colors.white : cs.onSurface;
    final subtleColor = dark ? Colors.white70 : cs.onSurfaceVariant;
    final chipColor = dark
        ? Colors.white.withValues(alpha: 0.08)
        : cs.surfaceContainerHighest.withValues(alpha: 0.6);

    return PopupMenuButton<String>(
      tooltip: '',
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 320),
      itemBuilder: (context) => [
        for (final ws in workspaces)
          PopupMenuItem<String>(
            value: ws.id,
            child: _WorkspaceRow(workspace: ws, isActive: ws.id == active.id),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: _manageAction,
          child: _ActionRow(
            icon: Icons.settings_outlined,
            label: 'Gerenciar workspaces',
          ),
        ),
      ],
      onSelected: (value) => _onSelected(context, ref, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: chipColor,
        ),
        child: Row(
          children: [
            _WorkspaceIcon(workspace: active, dark: dark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                active.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.unfold_more, size: 18, color: subtleColor),
          ],
        ),
      ),
    );
  }

  void _closeDrawerIfOpen(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
  }

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    if (value == _manageAction) {
      _closeDrawerIfOpen(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkspacesScreen()),
      );
      return;
    }

    if (ref.read(activeWorkspaceIdNotifierProvider) == value) {
      _closeDrawerIfOpen(context);
      return;
    }
    await ref.read(activeWorkspaceIdNotifierProvider.notifier).setActive(value);
    if (!context.mounted) return;
    _closeDrawerIfOpen(context);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }
}

class _WorkspaceIcon extends StatelessWidget {
  const _WorkspaceIcon({required this.workspace, required this.dark});

  final Workspace workspace;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isLocal = workspace.type == WorkspaceType.local;
    final icon = isLocal
        ? Icons.smartphone_outlined
        : (workspace.isLoggedIn
            ? Icons.cloud_done_outlined
            : Icons.cloud_off_outlined);
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: dark ? Colors.white.withValues(alpha: 0.12) : cs.primaryContainer,
      ),
      child: Icon(
        icon,
        size: 15,
        color: dark ? Colors.white : cs.onPrimaryContainer,
      ),
    );
  }
}

class _WorkspaceRow extends StatelessWidget {
  const _WorkspaceRow({required this.workspace, required this.isActive});

  final Workspace workspace;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isLocal = workspace.type == WorkspaceType.local;
    final subtitle = isLocal
        ? 'Local — não sincroniza'
        : (workspace.isLoggedIn
            ? (workspace.userEmail ?? 'Conectado')
            : 'Desconectado');
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _WorkspaceIcon(workspace: workspace, dark: false),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                workspace.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        if (isActive) ...[
          const SizedBox(width: 8),
          Icon(Icons.check, size: 18, color: cs.primary),
        ],
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
