import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../domain/plant_model.dart';
import '../providers/plants_providers.dart';
import '../widgets/plant_list_item.dart';
import 'plant_detail_screen.dart';
import '../../../../core/theme/glass_colors.dart';

/// Lists the active plants of a single location or species, with a
/// bulk-entry action that creates one entry for every plant shown.
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
              .where((p) => p.plant.isActive)
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
        iconTheme: IconThemeData(color: context.glass.fg),
        title: Text(
          title,
          style: TextStyle(
            color: context.glass.fg,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: context.glass.shadow(Colors.black45),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        bottom: speciesId == null
            ? null
            : _SurvivalLine(speciesId: speciesId!),
        actions: [
          if (plants.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.water_drop_outlined),
              tooltip: context.l10n.waterAll,
              onPressed: () => _waterAll(context, ref, plants),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.glass.scrim(0.5),
                    Colors.transparent,
                    context.glass.scrim(0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: plantsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: context.glass.fg),
              ),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.errorGeneric('$e'),
                  style: TextStyle(color: context.glass.fg),
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
                    showPot: true,
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

Future<void> _waterAll(
    BuildContext context, WidgetRef ref, List<PlantWithSpecies> plants) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await ref
        .read(entryMutationsProvider)
        .recordIrrigation(plants.map((p) => p.plant.id));
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.irrigationRecordedForPlants(plants.length)),
      duration: const Duration(seconds: 2),
    ));
  } catch (e) {
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.irrigationRecordError('$e')),
      backgroundColor: Colors.red,
    ));
  }
}

/// One-line survival rate of the species under the app bar title, counting
/// the plants that are no longer active too.
class _SurvivalLine extends ConsumerWidget implements PreferredSizeWidget {
  final String speciesId;

  const _SurvivalLine({required this.speciesId});

  @override
  Size get preferredSize => const Size.fromHeight(24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final survival = ref.watch(speciesSurvivalProvider(speciesId)).value;
    if (survival == null || survival.total == 0) {
      return const SizedBox.shrink();
    }
    final percent = (survival.alive * 100 / survival.total).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          context.l10n
              .speciesSurvivalRate(survival.total, percent, survival.alive),
          style: TextStyle(fontSize: 13, color: context.glass.fgMuted),
        ),
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
            color: context.glass.tint(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isLocation
                ? context.l10n.noPlantsAtLocation
                : context.l10n.noPlantsOfSpecies,
            style: TextStyle(color: context.glass.fg, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isLocation
                ? context.l10n.plantsAtLocationHint
                : context.l10n.plantsOfSpeciesHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.glass.fgMuted),
          ),
        ],
      ),
    );
  }
}
