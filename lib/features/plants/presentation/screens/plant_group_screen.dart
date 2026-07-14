import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../domain/plant_model.dart';
import '../providers/plants_providers.dart';
import '../widgets/plant_list_item.dart';
import 'plant_detail_screen.dart';

/// Lists the plants of a single location or species, with a bulk-entry
/// action that creates one entry for every plant shown.
class PlantGroupScreen extends ConsumerWidget {
  final String title;
  final String? locationId;
  final String? speciesId;

  const PlantGroupScreen.byLocation({
    super.key,
    required this.title,
    required String this.locationId,
  }) : speciesId = null;

  const PlantGroupScreen.bySpecies({
    super.key,
    required this.title,
    required String this.speciesId,
  }) : locationId = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsWithSpeciesProvider).whenData(
          (plants) => plants
              .where((p) => locationId != null
                  ? p.plant.locationId == locationId
                  : p.plant.speciesId == speciesId)
              .toList(),
        );
    final plants = plantsAsync.value ?? const <PlantWithSpecies>[];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
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
            child: plantsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.errorGeneric('$e'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (plants) {
                if (plants.isEmpty) {
                  return _EmptyState(isLocation: locationId != null);
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
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
      floatingActionButton: plants.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEntryScreen.bulk(
                    plantIds: plants.map((p) => p.plant.id).toList(),
                  ),
                ),
              ),
              icon: const Icon(Icons.playlist_add),
              label: Text(context.l10n.bulkEntryButton),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isLocation;

  const _EmptyState({required this.isLocation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_florist_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isLocation
                ? context.l10n.noPlantsAtLocation
                : context.l10n.noPlantsOfSpecies,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isLocation
                ? context.l10n.plantsAtLocationHint
                : context.l10n.plantsOfSpeciesHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
