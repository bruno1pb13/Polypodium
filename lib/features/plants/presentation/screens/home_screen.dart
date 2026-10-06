import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../../species/presentation/screens/species_list_screen.dart';
// ignore: unused_import
import '../../../locations/presentation/screens/locations_list_screen.dart';
import '../../../../core/links/app_link_handler.dart';
import '../../../../core/sync/auto_sync_controller.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../labels/data/label_scanner.dart';
import '../../../labels/presentation/screens/plant_labels_screen.dart';
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
import '../../../../core/theme/glass_colors.dart';

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
    final choice = await showDialog<_DeleteChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deletePlantsTitle(plantIds.length)),
        content: Text(
            '${ctx.l10n.deletePlantsBody}\n\n${ctx.l10n.deletePlantsArchiveHint}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _DeleteChoice.archive),
            child: Text(ctx.l10n.plantStatusArchive),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _DeleteChoice.delete),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );
    if (choice == null) return;
    final notifier = ref.read(plantsNotifierProvider.notifier);
    for (final id in plantIds) {
      switch (choice) {
        case _DeleteChoice.archive:
          await notifier.setStatus(id, PlantStatus.archived);
        case _DeleteChoice.delete:
          await notifier.delete(id);
      }
    }
    ref.read(plantSelectionProvider.notifier).state = {};
  }

  Future<void> _waterSelected(Set<String> plantIds) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(entryMutationsProvider).recordIrrigation(plantIds);
      ref.read(plantSelectionProvider.notifier).state = {};
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.irrigationRecordedForPlants(plantIds.length)),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.irrigationRecordError('$e')),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _bulkEntryForSelected(Set<String> plantIds) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEntryScreen.bulk(plantIds: plantIds.toList()),
      ),
    );
    if (mounted) ref.read(plantSelectionProvider.notifier).state = {};
  }

  /// Labels follow the list's order, not the order of selection.
  Future<void> _labelsForSelected(Set<String> plantIds) async {
    final listed = ref.read(filteredSortedPlantsProvider).value ?? const [];
    final ordered = [
      for (final p in listed)
        if (plantIds.contains(p.plant.id)) p.plant.id,
    ];
    final rest = plantIds.where((id) => !ordered.contains(id));
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantLabelsScreen(plantIds: [...ordered, ...rest]),
      ),
    );
    if (mounted) ref.read(plantSelectionProvider.notifier).state = {};
  }

  Future<void> _scanLabel() async {
    final navigator = Navigator.of(context);
    final code = await ref.read(labelScannerProvider).scan(context);
    if (code == null || !mounted) return;
    await openScannedLabel(
        navigator, code, ref.read(plantsRepositoryProvider).getById);
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
    final showArchived = ref.watch(plantShowArchivedNotifierProvider);
    final hasAnyPlant =
        ref.watch(plantsWithSpeciesProvider).value?.isNotEmpty ?? false;
    final scanner = ref.watch(labelScannerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: isSelectionMode
          ? AppBar(
              backgroundColor: Colors.black87,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
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
                  icon: const Icon(Icons.water_drop_outlined),
                  tooltip: context.l10n.waterSelected,
                  onPressed: () => _waterSelected(selectedIds),
                ),
                IconButton(
                  icon: const Icon(Icons.playlist_add),
                  tooltip: context.l10n.bulkEntrySelected,
                  onPressed: () => _bulkEntryForSelected(selectedIds),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_2),
                  tooltip: context.l10n.labelsGenerate,
                  onPressed: () => _labelsForSelected(selectedIds),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.l10n.deleteSelected,
                  onPressed: () =>
                      _confirmBulkDelete(context, ref, selectedIds),
                ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: context.glass.fg),
              title: MediaQuery.sizeOf(context).width >= kWideBreakpoint
                  ? null
                  : Text(
                      context.l10n.navMyPlants,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.glass.fg,
                        shadows: [
                          Shadow(
                            color: context.glass.shadow(Colors.black45),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
              actions: [
                if (scanner.isSupported)
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: context.l10n.labelScan,
                    onPressed: _scanLabel,
                  ),
                if (workspace.isLoggedIn)
                  IconButton(
                    icon: syncState.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.glass.fg,
                            ),
                          )
                        : const Icon(Icons.sync),
                    tooltip: context.l10n.syncNow,
                    onPressed: syncState.isLoading ? null : _manualSync,
                  ),
              ],
            ),
      // Opened from the dashboard, it goes back there instead.
      drawer: MediaQuery.sizeOf(context).width >= kWideBreakpoint ||
              Navigator.canPop(context)
          ? null
          : const AppDrawer(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
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
                    context.glass.scrim(0.5),
                    Colors.transparent,
                    context.glass.scrim(0.2),
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
                    const PopupMenuDivider(),
                    CheckedPopupMenuItem(
                      checked: showArchived,
                      onTap: () => ref
                          .read(plantShowArchivedNotifierProvider.notifier)
                          .toggle(),
                      child: Text(context.l10n.showArchivedPlants),
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: plantsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                            child: Text(context.l10n.errorLoadingPlants('$e'),
                                style: TextStyle(color: context.glass.fg))),
                        data: (plants) {
                          if (plants.isEmpty) {
                            return LayoutBuilder(
                              builder: (_, constraints) =>
                                  SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: _searchController.text.isNotEmpty
                                      ? Center(
                                          child: Text(
                                              context.l10n.noPlantsFound,
                                              style: TextStyle(
                                                  color: context.glass.fg)))
                                      : !showArchived && hasAnyPlant
                                          ? const _AllArchivedState()
                                          : const _EmptyState(),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            key: const ValueKey('plants-list'),
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
                                  ref
                                      .read(plantSelectionProvider.notifier)
                                      .state = current;
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
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              tooltip: context.l10n.addPlant,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditPlantScreen()),
              ),
              child: const Icon(Icons.add),
            ),
    );
  }
}

enum _DeleteChoice { archive, delete }

/// Shown when plants exist but none is active and archived ones are hidden.
class _AllArchivedState extends StatelessWidget {
  const _AllArchivedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: context.glass.tint(0.4)),
            const SizedBox(height: 16),
            Text(context.l10n.allPlantsArchived,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.glass.fg, fontSize: 16)),
            const SizedBox(height: 8),
            Text(context.l10n.allPlantsArchivedHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.glass.fgMuted)),
          ],
        ),
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
              size: 64, color: context.glass.tint(0.4)),
          const SizedBox(height: 16),
          Text(context.l10n.noPlantsRegistered,
              style: TextStyle(color: context.glass.fg, fontSize: 16)),
          const SizedBox(height: 8),
          Text(context.l10n.tapToAddFirstPlant,
              style: TextStyle(fontSize: 13, color: context.glass.fgMuted)),
        ],
      ),
    );
  }
}
