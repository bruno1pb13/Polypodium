import 'package:flutter/material.dart';

/// Two-step "server URL, then credentials" dialog shared by the flows that
/// need to authenticate against a Polypodium server: adding a new remote
/// workspace and reconnecting an existing one. [onSubmit] performs the
/// actual login and should rethrow on failure so the dialog can show it.
class WorkspaceLoginDialog extends StatefulWidget {
  const WorkspaceLoginDialog({
    super.key,
    required this.title,
    required this.checkServer,
    required this.onSubmit,
    this.initialServerUrl,
    this.initialEmail,
    this.serverUrlEditable = true,
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

  late int _step = widget.serverUrlEditable ? 0 : 1;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
      await widget.checkServer(_urlController.text.trim());
      if (mounted) {
        setState(() {
          _step = 1;
          _loading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro inesperado ao conectar.';
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
      await widget.onSubmit(
        _urlController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro inesperado ao entrar.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_step == 0 ? 'Endereço do servidor' : widget.title),
      content: _step == 0 ? _buildServerStep() : _buildCredStep(),
      actions: _step == 0 ? _serverActions() : _credActions(),
    );
  }

  Widget _buildServerStep() {
    return Form(
      key: _serverFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL do servidor',
              hintText: 'https://meu-servidor.com',
              prefixIcon: Icon(Icons.dns_outlined),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
            autofocus: true,
            onFieldSubmitted: (_) => _checkServer(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Obrigatório';
              }
              if (!v.trim().startsWith('http')) {
                return 'Deve começar com http:// ou https://';
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
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              autofocus: true,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
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
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
            ),
            if (_error != null) _buildErrorRow(),
          ],
        ),
      ),
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
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _loading ? null : _checkServer,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Próximo'),
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
          child: Text(widget.serverUrlEditable ? 'Voltar' : 'Cancelar'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Entrar'),
        ),
      ];
}
