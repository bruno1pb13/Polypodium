import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../species/presentation/screens/species_list_screen.dart';
import '../../../locations/presentation/screens/locations_list_screen.dart';
import '../providers/plants_providers.dart';
import '../providers/plant_search_providers.dart';
import '../../../../core/enums.dart';
import '../widgets/plant_list_item.dart';
import 'add_edit_plant_screen.dart';
import 'plant_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(filteredSortedPlantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PlantLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Localizações',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationsListScreen()),
            ),
          ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar plantas...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) {
                        ref
                            .read(plantSearchQueryProvider.notifier)
                            .setQuery(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<PlantSortOption>(
                    icon: Icon(Icons.tune,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onSelected: (option) {
                      ref
                          .read(plantSortOptionNotifierProvider.notifier)
                          .setSortOption(option);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: PlantSortOption.wateringNeeds,
                        child: Text('Necessidade de rega'),
                      ),
                      const PopupMenuItem(
                        value: PlantSortOption.nameAZ,
                        child: Text('Nome (A-Z)'),
                      ),
                      const PopupMenuItem(
                        value: PlantSortOption.nameZA,
                        child: Text('Nome (Z-A)'),
                      ),
                      const PopupMenuItem(
                        value: PlantSortOption.lastWatered,
                        child: Text('Última rega'),
                      ),
                      const PopupMenuItem(
                        value: PlantSortOption.dateAdded,
                        child: Text('Data de adição'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: plantsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erro ao carregar plantas: $e')),
              data: (plants) {
                if (plants.isEmpty) {
                  return _searchController.text.isNotEmpty
                      ? const Center(child: Text('Nenhuma planta encontrada'))
                      : const _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: plants.length,
                  itemBuilder: (ctx, i) => PlantListItem(
                    plantWithSpecies: plants[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PlantDetailScreen(plantId: plants[i].plant.id),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
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
