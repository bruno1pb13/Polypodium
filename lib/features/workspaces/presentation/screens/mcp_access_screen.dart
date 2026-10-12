import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sync/sync_exceptions.dart';
import '../../data/garden_client.dart';
import '../../data/mcp_token_client.dart';
import '../../domain/garden.dart';
import '../../domain/mcp_token.dart';
import '../../domain/workspace_model.dart';

/// The tokens AI assistants (MCP clients) connect to the garden a remote
/// workspace syncs. Each member creates and revokes their own; the owner
/// also sees and revokes everyone else's. The secret is shown once, right
/// after creation.
class McpAccessScreen extends StatefulWidget {
  const McpAccessScreen({
    super.key,
    required this.workspace,
    this.gardenClient = const GardenClient(),
    this.client = const McpTokenClient(),
  });

  final Workspace workspace;
  final GardenClient gardenClient;
  final McpTokenClient client;

  @override
  State<McpAccessScreen> createState() => _McpAccessScreenState();
}

typedef _McpView = ({Garden garden, List<McpToken> tokens});

class _McpAccessScreenState extends State<McpAccessScreen> {
  late Future<_McpView> _view = _load();

  String get _serverUrl => widget.workspace.serverUrl!;
  String get _token => widget.workspace.token!;

  Future<_McpView> _load() async {
    final gardens = await widget.gardenClient
        .listGardens(serverUrl: _serverUrl, token: _token);
    final garden = workspaceGarden(gardens, widget.workspace.gardenId) ??
        (throw const GardenAccessDeniedException());
    final tokens = await widget.client
        .listTokens(serverUrl: _serverUrl, token: _token, gardenId: garden.id);
    return (garden: garden, tokens: tokens);
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

  Future<void> _create(Garden garden) async {
    final request = await showDialog<({String name, bool canWrite})>(
      context: context,
      builder: (_) => const _NewTokenDialog(),
    );
    if (request == null || request.name.isEmpty) return;
    final CreatedMcpToken created;
    try {
      created = await widget.client.createToken(
        serverUrl: _serverUrl,
        token: _token,
        gardenId: garden.id,
        name: request.name,
        canWrite: request.canWrite,
      );
    } catch (e) {
      _showError(e);
      return;
    }
    _reload();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreatedTokenDialog(
        secret: created.secret,
        endpoint: mcpEndpoint(_serverUrl),
      ),
    );
  }

  Future<void> _revoke(Garden garden, McpToken token) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mcpRevokeTitle),
        content: Text(l10n.mcpRevokeBody(token.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.mcpRevoke,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.client.revokeToken(
          serverUrl: _serverUrl,
          token: _token,
          gardenId: garden.id,
          tokenId: token.id);
    } catch (e) {
      _showError(e);
      return;
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_McpView>(
      future: _view,
      builder: (context, snapshot) {
        final view = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.mcpAccess)),
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
                child: _TokenList(
                  view: view!,
                  endpoint: mcpEndpoint(_serverUrl),
                  selfEmail: widget.workspace.userEmail,
                  onRevoke: (t) => _revoke(view.garden, t),
                ),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          floatingActionButton: view == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _create(view.garden),
                  icon: const Icon(Icons.key_outlined),
                  label: Text(context.l10n.mcpNewToken),
                ),
        );
      },
    );
  }
}

Future<void> _copy(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(context.l10n.mcpCopied)));
}

class _TokenList extends StatelessWidget {
  const _TokenList({
    required this.view,
    required this.endpoint,
    required this.selfEmail,
    required this.onRevoke,
  });

  final _McpView view;
  final String endpoint;
  final String? selfEmail;
  final void Function(McpToken token) onRevoke;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = DateFormat.yMd(l10n.localeName);
    return ListView(
      // Clears the FAB.
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(l10n.mcpIntro),
        ),
        ListTile(
          leading: const Icon(Icons.link),
          title: Text(l10n.mcpEndpoint),
          subtitle: SelectableText(endpoint),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            tooltip: l10n.mcpCopy,
            onPressed: () => _copy(context, endpoint),
          ),
        ),
        const Divider(height: 1),
        if (view.tokens.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.mcpNoTokens, textAlign: TextAlign.center),
          ),
        for (final token in view.tokens)
          ListTile(
            leading: Icon(token.canWrite
                ? Icons.edit_note_outlined
                : Icons.visibility_outlined),
            title: Text(token.name, overflow: TextOverflow.ellipsis),
            subtitle: Text([
              '${token.tokenPrefix}… · '
                  '${token.canWrite ? l10n.mcpReadWrite : l10n.mcpReadOnly}',
              if (token.email != null && token.email != selfEmail)
                token.email!,
              token.lastUsedAt == null
                  ? l10n.mcpNeverUsed
                  : l10n.mcpLastUsed(date.format(token.lastUsedAt!.toLocal())),
            ].join('\n')),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.mcpRevokeTooltip(token.name),
              onPressed: () => onRevoke(token),
            ),
          ),
      ],
    );
  }
}

/// Asks for the token's name and whether it may change the garden.
class _NewTokenDialog extends StatefulWidget {
  const _NewTokenDialog();

  @override
  State<_NewTokenDialog> createState() => _NewTokenDialogState();
}

class _NewTokenDialogState extends State<_NewTokenDialog> {
  final _controller = TextEditingController();
  var _canWrite = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(
      context, (name: _controller.text.trim(), canWrite: _canWrite));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.mcpNewToken),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 100,
            decoration: InputDecoration(labelText: l10n.mcpTokenNameLabel),
            onSubmitted: (_) => _submit(),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _canWrite,
            onChanged: (v) => setState(() => _canWrite = v),
            title: Text(l10n.mcpAllowWrite),
            subtitle: Text(l10n.mcpAllowWriteHint),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.mcpCreate)),
      ],
    );
  }
}

/// Shows the new secret once, with a ready-made Claude Code command.
class _CreatedTokenDialog extends StatelessWidget {
  const _CreatedTokenDialog({required this.secret, required this.endpoint});

  final String secret;
  final String endpoint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final command = 'claude mcp add --transport http polypodium $endpoint '
        '--header "Authorization: Bearer $secret"';
    final mono = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(fontFamily: 'monospace');
    return AlertDialog(
      title: Text(l10n.mcpTokenCreatedTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mcpTokenCreatedBody),
            const SizedBox(height: 12),
            _CopyableText(text: secret, style: mono),
            const SizedBox(height: 16),
            Text(l10n.mcpClaudeCodeCommand,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            _CopyableText(text: command, style: mono),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.mcpDone),
        ),
      ],
    );
  }
}

class _CopyableText extends StatelessWidget {
  const _CopyableText({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SelectableText(text, style: style)),
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: context.l10n.mcpCopy,
          onPressed: () => _copy(context, text),
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
