import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../reminders/presentation/widgets/plant_reminders_card.dart';
import '../../../soils/presentation/providers/soils_providers.dart';
import '../../../species/presentation/providers/species_providers.dart';
import '../../domain/plant_model.dart';
import '../providers/plant_detail_view_provider.dart';
import '../providers/plants_providers.dart';
import '../widgets/plant_detail/plant_detail_actions.dart';
import '../widgets/plant_detail/plant_detail_header.dart';
import '../widgets/plant_detail/plant_detail_view_selector.dart';
import '../widgets/plant_detail/plant_diary_sliver.dart';
import '../widgets/plant_detail/plant_entries_header.dart';
import '../widgets/plant_detail/plant_info_card.dart';
import '../widgets/plant_detail/plant_status_banners.dart';
import '../widgets/plant_insights_view.dart';
import '../widgets/plant_photos_sliver.dart';
import 'add_edit_plant_screen.dart';

class PlantDetailScreen extends ConsumerWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsNotifierProvider);
    final speciesAsync = ref.watch(speciesNotifierProvider);
    final locationsAsync = ref.watch(locationsNotifierProvider);
    final soilsAsync = ref.watch(soilsNotifierProvider);
    final entriesAsync = ref.watch(entriesNotifierProvider(plantId));
    final activeView = ref.watch(plantDetailViewNotifierProvider(plantId));

    return plantsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text(context.l10n.errorGeneric('$e')))),
      data: (plants) {
        final plant = plants.where((p) => p.id == plantId).firstOrNull;
        if (plant == null) {
          return Scaffold(
            body: Center(child: Text(context.l10n.plantNotFound)),
          );
        }
        final species = speciesAsync.value
            ?.where((s) => s.id == plant.speciesId)
            .firstOrNull;

        final location = plant.locationId != null
            ? locationsAsync.value
                ?.where((l) => l.id == plant.locationId)
                .firstOrNull
            : null;

        final soil = soilsAsync.value
            ?.where((s) => s.id == plant.soilId)
            .firstOrNull;

        final pws = species != null
            ? PlantWithSpecies(
                plant: plant,
                species: species,
                location: location,
              )
            : null;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              plant.nickname,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditPlantScreen(plant: plant),
                  ),
                ),
              ),
              PlantStatusMenuButton(plant: plant),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => confirmDeletePlant(context, ref, plantId),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(plantsNotifierProvider);
                    ref.invalidate(entriesNotifierProvider(plantId));
                    try {
                      await Future.wait([
                        ref.read(plantsNotifierProvider.future),
                        ref.read(entriesNotifierProvider(plantId).future),
                      ]);
                    } catch (_) {}
                  },
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PlantDetailHeader(plant: plant, pws: pws),
                    ),
                    if (!plant.isActive)
                      SliverToBoxAdapter(
                        child: PlantLifecycleBanner(plant: plant),
                      ),
                    if (pws != null)
                      SliverToBoxAdapter(
                        child: PlantCareAlerts(pws: pws),
                      ),
                    SliverToBoxAdapter(
                      child: PlantInfoCard(plant: plant, pws: pws, soilName: soil?.name, soilComposition: soil?.composition),
                    ),
                    // Reminders of plants that are no longer active are
                    // ignored, so they aren't offered either.
                    if (plant.isActive)
                      SliverToBoxAdapter(
                        child: PlantRemindersCard(plantId: plantId),
                      ),
                    SliverToBoxAdapter(
                      child: PlantDetailViewSelector(plantId: plantId),
                    ),
                    if (activeView == PlantDetailView.diary) ...[
                      SliverToBoxAdapter(
                        child: PlantEntriesHeader(plantId: plantId),
                      ),
                      // Timeline Entries
                      PlantDiarySliver(plantId: plantId),
                    ] else if (activeView == PlantDetailView.charts)
                      entriesAsync.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => SliverToBoxAdapter(
                          child: Center(
                              child: Text(context.l10n.errorGeneric('$e'))),
                        ),
                        data: (entries) => SliverToBoxAdapter(
                          child:
                              PlantInsightsView(entries: entries, pws: pws),
                        ),
                      )
                    else
                      entriesAsync.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => SliverToBoxAdapter(
                          child: Center(
                              child: Text(context.l10n.errorGeneric('$e'))),
                        ),
                        data: (entries) =>
                            PlantPhotosSliver(entries: entries),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'add_entry',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEntryScreen(plantId: plantId),
                  ),
                ),
                child: const Icon(Icons.note_add_outlined),
              ),
              if (plant.isActive) ...[
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'irrigate',
                  onPressed: () => _irrigate(context, ref),
                  icon: const Icon(Icons.water_drop),
                  label: Text(context.l10n.wateredNow),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _irrigate(BuildContext context, WidgetRef ref) async {
    try {
      final entry = EntryModel(
        id: const Uuid().v4(),
        plantId: plantId,
        date: DateTime.now(),
        type: EntryType.irrigation,
        createdAt: DateTime.now(),
      );

      await ref.read(entriesNotifierProvider(plantId).notifier).create(entry);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.irrigationRecorded),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.irrigationRecordError('$e')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
