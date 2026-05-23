import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/species_providers.dart';
import 'add_species_screen.dart';

class SpeciesListScreen extends ConsumerWidget {
  const SpeciesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesAsync = ref.watch(speciesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Espécies')),
      body: speciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (species) {
          if (species.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Nenhuma espécie cadastrada'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: species.length,
            itemBuilder: (ctx, i) {
              final s = species[i];
              return ListTile(
                title: Text(s.popularName),
                subtitle: Text(
                  s.scientificName,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.defaultIrrigationFrequencyDays}d',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddSpeciesScreen(species: s),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, s.id),
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
          MaterialPageRoute(builder: (_) => const AddSpeciesScreen()),
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
        title: const Text('Deletar espécie?'),
        content:
            const Text('Plantas vinculadas a esta espécie não serão afetadas.'),
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
      await ref.read(speciesNotifierProvider.notifier).delete(id);
    }
  }
}
