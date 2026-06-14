import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import '../../../../core/sync/sync_providers.dart';

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
    final syncService = ref.watch(syncServiceProvider);
    final syncState = ref.watch(syncNotifierProvider);
    final pendingAsync = ref.watch(pendingSyncCountProvider);

    if (!syncService.isLoggedIn) {
      return ListTile(
        leading: const Icon(Icons.cloud_off_outlined),
        title: const Text('Não configurado'),
        subtitle: const Text('Conecte a um servidor para sincronizar entre dispositivos'),
        trailing: TextButton(
          onPressed: () => _showLoginDialog(context, ref),
          child: const Text('Configurar'),
        ),
      );
    }

    final lastSync = syncService.lastSyncAt;
    final lastSyncText = lastSync == null
        ? 'Nunca sincronizado'
        : 'Último sync: ${_formatRelative(lastSync)}';

    final pendingText = pendingAsync.when(
      data: (n) => n == 0 ? 'Tudo sincronizado' : '$n evento(s) pendente(s)',
      loading: () => '...',
      error: (_, __) => '',
    );

    final isLoading = syncState.isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_done_outlined),
          title: Text(syncService.userEmail ?? 'Conectado'),
          subtitle: Text(syncService.serverUrl ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Desconectar',
            onPressed: isLoading
                ? null
                : () => _confirmLogout(context, ref),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.sync_outlined),
          title: Text(lastSyncText),
          subtitle: Text(pendingText),
          trailing: syncState.hasError
              ? IconButton(
                  icon: const Icon(Icons.error_outline, color: Colors.red),
                  tooltip: syncState.error.toString(),
                  onPressed: () => _showError(context, syncState.error.toString()),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(isLoading ? 'Sincronizando...' : 'Sincronizar Agora'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLoginDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _LoginDialog(ref: ref),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desconectar'),
        content: const Text(
          'Seus dados locais não serão apagados. '
          'Para sincronizar novamente, faça login.',
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
      await ref.read(syncNotifierProvider.notifier).logout();
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }
}

// ---------------------------------------------------------------------------

class _LoginDialog extends StatefulWidget {
  const _LoginDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
  final _serverFormKey = GlobalKey<FormState>();
  final _credFormKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  int _step = 0;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final service = widget.ref.read(syncServiceProvider);
    if (service.serverUrl != null) _urlController.text = service.serverUrl!;
    if (service.userEmail != null) _emailController.text = service.userEmail!;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkServer() async {
    if (!_serverFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await widget.ref.read(syncServiceProvider).checkServer(_urlController.text.trim());
      if (mounted) setState(() { _step = 1; _loading = false; });
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
    if (!_credFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    await widget.ref.read(syncNotifierProvider.notifier).login(
      _urlController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    final state = widget.ref.read(syncNotifierProvider);
    if (state.hasError) {
      setState(() {
        _error = state.error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_step == 0 ? 'Endereço do servidor' : 'Entrar na conta'),
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
              if (v == null || v.trim().isEmpty) return 'Obrigatório';
              if (!v.trim().startsWith('http')) return 'Deve começar com http:// ou https://';
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
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
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
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
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Próximo'),
    ),
  ];

  List<Widget> _credActions() => [
    TextButton(
      onPressed: _loading ? null : () => setState(() { _step = 0; _error = null; }),
      child: const Text('Voltar'),
    ),
    FilledButton(
      onPressed: _loading ? null : _submit,
      child: _loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Entrar'),
    ),
  ];
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
