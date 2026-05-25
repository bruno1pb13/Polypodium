import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

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
