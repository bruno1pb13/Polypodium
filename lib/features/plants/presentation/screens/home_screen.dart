import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../../species/presentation/screens/species_list_screen.dart';
// ignore: unused_import
import '../../../locations/presentation/screens/locations_list_screen.dart';
import '../../../../core/sync/auto_sync_controller.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../providers/plant_search_providers.dart';
import '../providers/plant_selection_provider.dart';
import '../providers/plants_providers.dart';
import '../../../../core/enums.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_shell.dart';
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
    if (ref.read(activeWorkspaceProvider).isLoggedIn) {
      await ref.read(autoSyncControllerProvider.notifier).syncNow();
    }
    ref.invalidate(plantsNotifierProvider);
    try {
      await ref.read(filteredSortedPlantsProvider.future);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmBulkDelete(
    BuildContext context,
    WidgetRef ref,
    Set<String> plantIds,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deletePlantsTitle(plantIds.length)),
        content: Text(ctx.l10n.deletePlantsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      for (final id in plantIds) {
        await ref.read(plantsNotifierProvider.notifier).delete(id);
      }
      ref.read(plantSelectionProvider.notifier).state = {};
    }
  }

  Future<void> _manualSync() async {
    await ref.read(syncNotifierProvider.notifier).sync();
    if (!mounted) return;
    final state = ref.read(syncNotifierProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizedErrorMessage(state.error!, context.l10n)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(filteredSortedPlantsProvider);
    final selectedIds = ref.watch(plantSelectionProvider);
    final isSelectionMode = selectedIds.isNotEmpty;
    final workspace = ref.watch(activeWorkspaceProvider);
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: isSelectionMode
          ? AppBar(
              backgroundColor: Colors.black87,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: context.l10n.cancelSelection,
                onPressed: () =>
                    ref.read(plantSelectionProvider.notifier).state = {},
              ),
              title: Text(
                context.l10n.selectedCount(selectedIds.length),
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.l10n.deleteSelected,
                  onPressed: () => _confirmBulkDelete(context, ref, selectedIds),
                ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              title: MediaQuery.sizeOf(context).width >= kWideBreakpoint
                  ? null
                  : const Text(
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
              actions: [
                if (workspace.isLoggedIn)
                  IconButton(
                    icon: syncState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync),
                    tooltip: context.l10n.syncNow,
                    onPressed: syncState.isLoading ? null : _manualSync,
                  ),
              ],
            ),
      drawer: MediaQuery.sizeOf(context).width >= kWideBreakpoint
          ? null
          : const AppDrawer(),
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
                  hintText: context.l10n.searchPlantsHint,
                  onChanged: (value) {
                    ref.read(plantSearchQueryProvider.notifier).setQuery(value);
                  },
                  onSortSelected: (option) {
                    ref
                        .read(plantSortOptionNotifierProvider.notifier)
                        .setSortOption(option);
                  },
                  sortOptions: [
                    PopupMenuItem(
                      value: PlantSortOption.wateringNeeds,
                      child: Text(context.l10n.sortWateringNeeds),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.nameAZ,
                      child: Text(context.l10n.sortNameAZ),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.nameZA,
                      child: Text(context.l10n.sortNameZA),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.lastWatered,
                      child: Text(context.l10n.sortLastWatered),
                    ),
                    PopupMenuItem(
                      value: PlantSortOption.dateAdded,
                      child: Text(context.l10n.sortDateAdded),
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
                          child: Text(context.l10n.errorLoadingPlants('$e'),
                              style: const TextStyle(color: Colors.white))),
                      data: (plants) {
                        if (plants.isEmpty) {
                          return LayoutBuilder(
                            builder: (_, constraints) => SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: _searchController.text.isNotEmpty
                                    ? Center(
                                        child: Text(context.l10n.noPlantsFound,
                                            style: const TextStyle(
                                                color: Colors.white)))
                                    : const _EmptyState(),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: plants.length,
                          itemBuilder: (ctx, i) {
                            final plantId = plants[i].plant.id;
                            return PlantListItem(
                              plantWithSpecies: plants[i],
                              isSelectionMode: isSelectionMode,
                              isSelected: selectedIds.contains(plantId),
                              onStartSelection: () => ref
                                  .read(plantSelectionProvider.notifier)
                                  .state = {plantId},
                              onToggleSelect: () {
                                final current = Set<String>.from(selectedIds);
                                if (!current.remove(plantId)) {
                                  current.add(plantId);
                                }
                                ref.read(plantSelectionProvider.notifier).state =
                                    current;
                              },
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlantDetailScreen(plantId: plantId),
                                ),
                              ),
                            );
                          },
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
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
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
          Text(context.l10n.noPlantsRegistered,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          Text(context.l10n.tapToAddFirstPlant,
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }
}
