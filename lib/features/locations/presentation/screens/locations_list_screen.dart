import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locations_providers.dart';
import 'add_edit_location_screen.dart';

class LocationsListScreen extends ConsumerWidget {
  const LocationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Localizações')),
      body: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (locations) {
          if (locations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Nenhuma localização cadastrada'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (ctx, i) {
              final loc = locations[i];
              return ListTile(
                title: Text(loc.name),
                subtitle:
                    loc.description != null ? Text(loc.description!) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditLocationScreen(location: loc),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, loc.id),
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
          MaterialPageRoute(builder: (_) => const AddEditLocationScreen()),
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
        title: const Text('Deletar localização?'),
        content: const Text(
            'Plantas vinculadas a esta localização não serão deletadas, mas ficarão sem localização.'),
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
      await ref.read(locationsNotifierProvider.notifier).delete(id);
    }
  }
}
