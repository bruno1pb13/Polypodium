import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/species_providers.dart';
import '../../data/external_species_repository.dart';
import 'add_species_screen.dart';

class SpeciesListScreen extends ConsumerWidget {
  const SpeciesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesAsync = ref.watch(speciesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Espécies')),
      body: Column(
        children: [
          _buildInfoBanner(context, ref),
          Expanded(
            child: speciesAsync.when(
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
          ),
        ],
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

  Widget _buildInfoBanner(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Usando dados oficiais da Flora e Funga do Brasil (JBRJ).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<int>(
            future: ref
                .read(externalSpeciesRepositoryProvider.notifier)
                .getSpeciesCount(),
            builder: (context, snapshot) {
              return Text(
                'Total de espécies disponíveis: ${snapshot.data ?? "..."}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              );
            },
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: ref
                .read(externalSpeciesRepositoryProvider.notifier)
                .getLastUpdateDate(),
            builder: (context, snapshot) {
              return Text(
                'Última atualização: ${snapshot.data ?? "..."}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _handleUpdate(context, ref),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Baixar versão atualizada (JBRJ)'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Iniciando download do dataset oficial...')),
    );

    try {
      await ref.read(externalSpeciesRepositoryProvider.notifier).downloadAndUpdate();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Dataset atualizado com sucesso!')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    }
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
