import 'package:flutter/material.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';

/// "Server URL, then credentials" dialog shared by the flows that need to
/// talk to a Polypodium server: adding a new remote workspace, reconnecting
/// an existing one, and (when [checkHasUsers] reports an empty server) the
/// first-run onboarding to create that server's very first account.
///
/// [onSubmit] performs a normal login and should rethrow on failure so the
/// dialog can show it. When [checkHasUsers] is provided and reports the
/// server has no accounts yet, the credentials step switches to a
/// registration form and calls [onRegister] instead; on success, if
/// [hasLocalDataToMigrate] resolves true, a final step offers to send the
/// local workspace's data to the server via [onMigrate].
class WorkspaceLoginDialog extends StatefulWidget {
  const WorkspaceLoginDialog({
    super.key,
    required this.title,
    required this.checkServer,
    required this.onSubmit,
    this.initialServerUrl,
    this.initialEmail,
    this.serverUrlEditable = true,
    this.checkHasUsers,
    this.onRegister,
    this.hasLocalDataToMigrate,
    this.onMigrate,
  });

  final String title;
  final Future<void> Function(String serverUrl) checkServer;
  final Future<void> Function(String serverUrl, String email, String password)
      onSubmit;
  final String? initialServerUrl;
  final String? initialEmail;

  /// When false, the server-URL step is skipped (used for reconnecting an
  /// existing workspace, whose serverUrl is already fixed).
  final bool serverUrlEditable;

  /// When provided, checked right after the server responds to decide
  /// whether to show the login form or the first-account onboarding form.
  final Future<bool> Function(String serverUrl)? checkHasUsers;

  /// Creates the server's first account. Required when [checkHasUsers] is
  /// provided.
  final Future<void> Function(
      String serverUrl, String workspaceName, String email, String password)?
      onRegister;

  /// Whether the local workspace has data worth offering to migrate. Checked
  /// right after [onRegister] succeeds.
  final Future<bool> Function()? hasLocalDataToMigrate;

  /// Sends the local workspace's data to the server just registered on.
  final Future<void> Function()? onMigrate;

  @override
  State<WorkspaceLoginDialog> createState() => _WorkspaceLoginDialogState();
}

class _WorkspaceLoginDialogState extends State<WorkspaceLoginDialog> {
  final _serverFormKey = GlobalKey<FormState>();
  final _credFormKey = GlobalKey<FormState>();
  late final _urlController =
      TextEditingController(text: widget.initialServerUrl ?? '');
  late final _emailController =
      TextEditingController(text: widget.initialEmail ?? '');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _workspaceNameController = TextEditingController();

  late int _step = widget.serverUrlEditable ? 0 : 1;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _isRegisterMode = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _workspaceNameController.dispose();
    super.dispose();
  }

  Future<void> _checkServer() async {
    if (!_serverFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = _urlController.text.trim();
      await widget.checkServer(url);
      final hasUsers =
          widget.checkHasUsers != null ? await widget.checkHasUsers!(url) : true;
      if (mounted) {
        setState(() {
          _isRegisterMode = !hasUsers;
          _step = 1;
          _loading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = localizedErrorMessage(e, context.l10n);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = context.l10n.unexpectedConnectError;
          _loading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_credFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = _urlController.text.trim();
      if (_isRegisterMode) {
        await widget.onRegister!(
          url,
          _workspaceNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        final hasLocalData = widget.hasLocalDataToMigrate != null &&
            await widget.hasLocalDataToMigrate!();
        if (hasLocalData && mounted) {
          setState(() {
            _step = 2;
            _loading = false;
          });
          return;
        }
      } else {
        await widget.onSubmit(
          url,
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = localizedErrorMessage(e, context.l10n);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _isRegisterMode
              ? context.l10n.unexpectedRegisterError
              : context.l10n.unexpectedLoginError;
          _loading = false;
        });
      }
    }
  }

  Future<void> _migrate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onMigrate!();
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = localizedErrorMessage(e, context.l10n);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = context.l10n.unexpectedMigrateError;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      0 => context.l10n.serverAddressTitle,
      1 => _isRegisterMode
          ? context.l10n.createFirstAccountTitle
          : widget.title,
      _ => context.l10n.migrateLocalDataTitle,
    };
    final content = switch (_step) {
      0 => _buildServerStep(),
      1 => _buildCredStep(),
      _ => _buildMigrateStep(),
    };
    final actions = switch (_step) {
      0 => _serverActions(),
      1 => _credActions(),
      _ => _migrateActions(),
    };
    return AlertDialog(title: Text(title), content: content, actions: actions);
  }

  Widget _buildServerStep() {
    return Form(
      key: _serverFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: context.l10n.serverUrlLabel,
              hintText: 'https://my-server.com',
              prefixIcon: const Icon(Icons.dns_outlined),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
            autofocus: true,
            onFieldSubmitted: (_) => _checkServer(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return context.l10n.requiredShort;
              }
              if (!v.trim().startsWith('http')) {
                return context.l10n.mustStartWithHttp;
              }
              return null;
            },
          ),
          if (_error != null) _buildErrorRow(),
        ],
      ),
    );
  }

  Widget _buildCredStep() {
    return Form(
      key: _credFormKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns_outlined, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _urlController.text.trim(),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isRegisterMode) ..._buildRegisterFields(),
            if (!_isRegisterMode) ..._buildLoginFields(),
            if (_error != null) _buildErrorRow(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRegisterFields() {
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.celebration_outlined,
                size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.firstAccountInfo,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _workspaceNameController,
        decoration: InputDecoration(
          labelText: context.l10n.workspaceNameLabel,
          hintText: context.l10n.workspaceNameHint,
          prefixIcon: const Icon(Icons.label_outline),
        ),
        autofocus: true,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? context.l10n.requiredShort
            : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: context.l10n.emailLabel,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? context.l10n.requiredShort
            : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: context.l10n.passwordLabel,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        obscureText: _obscurePassword,
        validator: (v) {
          if (v == null || v.isEmpty) return context.l10n.requiredShort;
          if (v.length < 6) return context.l10n.passwordMinChars;
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _confirmPasswordController,
        decoration: InputDecoration(
          labelText: context.l10n.confirmPasswordLabel,
          prefixIcon: const Icon(Icons.lock_outlined),
        ),
        obscureText: _obscurePassword,
        onFieldSubmitted: (_) => _submit(),
        validator: (v) => v != _passwordController.text
            ? context.l10n.passwordsDontMatch
            : null,
      ),
    ];
  }

  List<Widget> _buildLoginFields() {
    return [
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: context.l10n.emailLabel,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        autofocus: true,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? context.l10n.requiredShort
            : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: context.l10n.passwordLabel,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        obscureText: _obscurePassword,
        onFieldSubmitted: (_) => _submit(),
        validator: (v) =>
            (v == null || v.isEmpty) ? context.l10n.requiredShort : null,
      ),
    ];
  }

  Widget _buildMigrateStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.migrateLocalDataBody),
        if (_error != null) _buildErrorRow(),
      ],
    );
  }

  Widget _buildErrorRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.error, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _serverActions() => [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _checkServer,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.l10n.next),
        ),
      ];

  List<Widget> _credActions() => [
        TextButton(
          onPressed: _loading
              ? null
              : () => widget.serverUrlEditable
                  ? setState(() {
                      _step = 0;
                      _error = null;
                    })
                  : Navigator.pop(context),
          child: Text(widget.serverUrlEditable
              ? context.l10n.back
              : context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isRegisterMode
                  ? context.l10n.createAccount
                  : context.l10n.signIn),
        ),
      ];

  List<Widget> _migrateActions() => [
        TextButton(
          onPressed:
              _loading ? null : () => Navigator.pop(context, true),
          child: Text(context.l10n.notNow),
        ),
        FilledButton(
          onPressed: _loading ? null : _migrate,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.l10n.migrate),
        ),
      ];
}
