import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
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
