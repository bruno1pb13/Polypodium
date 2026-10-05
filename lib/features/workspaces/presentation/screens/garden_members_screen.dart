import 'package:flutter/material.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sync/sync_exceptions.dart';
import '../../data/garden_client.dart';
import '../../domain/garden.dart';
import '../../domain/workspace_model.dart';
import '../widgets/garden_picker_dialog.dart';

/// Who shares the garden a remote workspace syncs. The owner adds members by
/// the e-mail of their account on the same server and removes them; a member
/// sees the list and can leave. Pops true after the user left the garden.
class GardenMembersScreen extends StatefulWidget {
  const GardenMembersScreen({
    super.key,
    required this.workspace,
    this.client = const GardenClient(),
  });

  final Workspace workspace;
  final GardenClient client;

  @override
  State<GardenMembersScreen> createState() => _GardenMembersScreenState();
}

typedef _GardenView = ({Garden garden, List<GardenMember> members});

class _GardenMembersScreenState extends State<GardenMembersScreen> {
  late Future<_GardenView> _view = _load();

  String get _serverUrl => widget.workspace.serverUrl!;
  String get _token => widget.workspace.token!;

  Future<_GardenView> _load() async {
    final gardens =
        await widget.client.listGardens(serverUrl: _serverUrl, token: _token);
    final gardenId = widget.workspace.gardenId;
    final matches = gardens
        .where((g) => gardenId == null ? g.isOwnPersonal : g.id == gardenId);
    if (matches.isEmpty) throw const GardenAccessDeniedException();
    final garden = matches.first;
    final members = await widget.client
        .listMembers(serverUrl: _serverUrl, token: _token, gardenId: garden.id);
    return (garden: garden, members: members);
  }

  void _reload() {
    setState(() {
      _view = _load();
    });
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _addMember(Garden garden) async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => const _AddMemberDialog(),
    );
    if (email == null || email.isEmpty) return;
    try {
      await widget.client.addMember(
          serverUrl: _serverUrl,
          token: _token,
          gardenId: garden.id,
          email: email);
    } catch (e) {
      _showError(e);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.gardenMemberAdded(email))));
    _reload();
  }

  Future<void> _removeMember(Garden garden, GardenMember member) async {
    final l10n = context.l10n;
    if (!await _confirm(
      title: l10n.gardenRemoveMemberTitle,
      message: l10n.gardenRemoveMemberBody(member.email),
      confirmLabel: l10n.gardenRemove,
    )) {
      return;
    }
    try {
      await widget.client.removeMember(
          serverUrl: _serverUrl,
          token: _token,
          gardenId: garden.id,
          userId: member.userId);
    } catch (e) {
      _showError(e);
      return;
    }
    _reload();
  }

  Future<void> _leave(Garden garden, GardenMember self) async {
    final l10n = context.l10n;
    if (!await _confirm(
      title: l10n.gardenLeave,
      message: l10n.gardenLeaveBody,
      confirmLabel: l10n.gardenLeave,
    )) {
      return;
    }
    try {
      await widget.client.removeMember(
          serverUrl: _serverUrl,
          token: _token,
          gardenId: garden.id,
          userId: self.userId);
    } catch (e) {
      _showError(e);
      return;
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GardenView>(
      future: _view,
      builder: (context, snapshot) {
        final view = snapshot.data;
        final isOwner = view?.garden.isOwner ?? false;
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.gardenMembers)),
          body: switch (snapshot) {
            AsyncSnapshot(:final Object error) => _ErrorBody(
                message: localizedErrorMessage(error, context.l10n),
                onRetry: _reload,
              ),
            AsyncSnapshot(hasData: true) => RefreshIndicator(
                onRefresh: () async {
                  _reload();
                  try {
                    await _view;
                  } catch (_) {}
                },
                child: _MembersList(
                  view: view!,
                  selfEmail: widget.workspace.userEmail,
                  onRemove:
                      isOwner ? (m) => _removeMember(view.garden, m) : null,
                  onLeave: isOwner ? null : (m) => _leave(view.garden, m),
                ),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          floatingActionButton: isOwner
              ? FloatingActionButton.extended(
                  onPressed: () => _addMember(view!.garden),
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(context.l10n.gardenAddMember),
                )
              : null,
        );
      },
    );
  }
}

/// Asks for the new member's e-mail; pops it trimmed, or null.
class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog();

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.gardenAddMember),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.gardenAddMemberHint),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(labelText: context.l10n.emailLabel),
            onSubmitted: (v) => Navigator.pop(context, v.trim()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(context.l10n.gardenAddMember),
        ),
      ],
    );
  }
}

class _MembersList extends StatelessWidget {
  const _MembersList({
    required this.view,
    required this.selfEmail,
    required this.onRemove,
    required this.onLeave,
  });

  final _GardenView view;
  final String? selfEmail;

  /// Set for the owner's view.
  final void Function(GardenMember member)? onRemove;

  /// Set for a member's view; receives the caller's own membership.
  final void Function(GardenMember self)? onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final garden = view.garden;
    final self = view.members.where((m) => m.email == selfEmail);
    return ListView(
      // Clears the FAB.
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        ListTile(
          leading: Icon(
              garden.personal ? Icons.person_outline : Icons.groups_outlined),
          title: Text(gardenDisplayName(garden, l10n),
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(garden.isOwner
              ? l10n.gardenYouAreOwner
              : l10n.gardenYouAreMember),
        ),
        const Divider(height: 1),
        for (final member in view.members)
          ListTile(
            leading: Icon(member.isOwner
                ? Icons.workspace_premium_outlined
                : Icons.person_outline),
            title: Text(
              member.email == selfEmail
                  ? l10n.gardenYou(member.email)
                  : member.email,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
                member.isOwner ? l10n.gardenRoleOwner : l10n.gardenRoleMember),
            trailing: onRemove != null && !member.isOwner
                ? IconButton(
                    icon: const Icon(Icons.person_remove_outlined),
                    tooltip: l10n.gardenRemoveMemberTooltip(member.email),
                    onPressed: () => onRemove!(member),
                  )
                : null,
          ),
        if (onLeave != null && self.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => onLeave!(self.first),
              icon: const Icon(Icons.logout),
              label: Text(l10n.gardenLeave),
            ),
          ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.l10n.gardenRetry),
            ),
          ],
        ),
      ),
    );
  }
}
