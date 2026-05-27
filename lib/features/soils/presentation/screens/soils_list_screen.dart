import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/soils_providers.dart';
import 'add_edit_soil_screen.dart';

class SoilsListScreen extends ConsumerWidget {
  const SoilsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilsAsync = ref.watch(soilsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Solos')),
      body: soilsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (soils) {
          if (soils.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.terrain_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Nenhum tipo de solo cadastrado'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: soils.length,
            itemBuilder: (ctx, i) {
              final soil = soils[i];
              return ListTile(
                leading: const Icon(Icons.terrain_outlined),
                title: Text(soil.name),
                subtitle: soil.composition != null ? Text(soil.composition!) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditSoilScreen(soil: soil),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, soil.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditSoilScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar solo?'),
        content: const Text(
            'Plantas e espécies vinculadas a este solo não serão deletadas, mas a referência ao solo pode ser perdida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(soilsNotifierProvider.notifier).delete(id);
    }
  }
}
