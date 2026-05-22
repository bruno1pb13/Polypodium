import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../species/presentation/screens/species_list_screen.dart';
import '../providers/plants_providers.dart';
import '../widgets/plant_list_item.dart';
import 'add_edit_plant_screen.dart';
import 'plant_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsWithSpeciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PlantLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.eco_outlined),
            tooltip: 'Espécies',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpeciesListScreen()),
            ),
          ),
        ],
      ),
      body: plantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar plantas: $e')),
        data: (plants) {
          if (plants.isEmpty) return const _EmptyState();

          // Sort: overdue first, then by days overdue descending
          final sorted = [...plants]..sort(
              (a, b) => b.daysRelativeToSchedule.compareTo(a.daysRelativeToSchedule),
            );

          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (ctx, i) => PlantListItem(
              plantWithSpecies: sorted[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PlantDetailScreen(plantId: sorted[i].plant.id),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPlantScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_florist_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Nenhuma planta cadastrada'),
          const SizedBox(height: 8),
          const Text('Toque em + para adicionar sua primeira planta.',
              style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
