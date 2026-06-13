import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../../species/presentation/screens/species_list_screen.dart';
// ignore: unused_import
import '../../../locations/presentation/screens/locations_list_screen.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../providers/plant_search_providers.dart';
import '../providers/plants_providers.dart';
import '../../../../core/enums.dart';
import '../../../../core/widgets/app_drawer.dart';
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

  Future<void> _refresh() async {
    ref.invalidate(plantsNotifierProvider);
    await ref.read(filteredSortedPlantsProvider.future).catchError((_) {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(filteredSortedPlantsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Polypodium',
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
            fontSize: 28,
            letterSpacing: 0.5,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay for better readability - darkened at top
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppSearchBar<PlantSortOption>(
                  controller: _searchController,
                  hintText: 'Buscar plantas...',
                  onChanged: (value) {
                    ref.read(plantSearchQueryProvider.notifier).setQuery(value);
                  },
                  onSortSelected: (option) {
                    ref
                        .read(plantSortOptionNotifierProvider.notifier)
                        .setSortOption(option);
                  },
                  sortOptions: const [
                    PopupMenuItem(
                      value: PlantSortOption.wateringNeeds,
                      child: Text('Necessidade de rega'),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.nameAZ,
                      child: Text('Nome (A-Z)'),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.nameZA,
                      child: Text('Nome (Z-A)'),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.lastWatered,
                      child: Text('Última rega'),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.dateAdded,
                      child: Text('Data de adição'),
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    child: plantsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                          child: Text('Erro ao carregar plantas: $e',
                              style: const TextStyle(color: Colors.white))),
                      data: (plants) {
                        if (plants.isEmpty) {
                          return LayoutBuilder(
                            builder: (_, constraints) => SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: _searchController.text.isNotEmpty
                                    ? const Center(
                                        child: Text('Nenhuma planta encontrada',
                                            style: TextStyle(color: Colors.white)))
                                    : const _EmptyState(),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: plants.length,
                          itemBuilder: (ctx, i) => PlantListItem(
                            plantWithSpecies: plants[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlantDetailScreen(
                                    plantId: plants[i].plant.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
              size: 64, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Nenhuma planta cadastrada',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Toque em + para adicionar sua primeira planta.',
              style: TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }
}
