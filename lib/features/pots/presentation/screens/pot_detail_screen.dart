import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../plants/domain/plant_model.dart';
import '../../../plants/presentation/screens/plant_detail_screen.dart';
import '../../domain/pot_with_plants.dart';
import '../providers/pots_providers.dart';
import '../widgets/plants_for_pot_sheet.dart';
import '../widgets/pot_actions.dart';
import '../widgets/pot_ui.dart';
import 'add_edit_pot_screen.dart';

/// A pot's data and the plants in it, with the actions that move them.
class PotDetailScreen extends ConsumerWidget {
  final String potId;

  const PotDetailScreen({super.key, required this.potId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final potAsync = ref.watch(potWithPlantsProvider(potId));
    final pot = potAsync.value;

    return PotScreenScaffold(
      title: pot?.pot.name ?? l10n.potLabel,
      actions: pot == null
          ? null
          : [
              if (pot.activePlants.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.water_drop_outlined),
                  tooltip: l10n.waterPot,
                  onPressed: () => waterPotPlants(
                    context,
                    ref.read(entryMutationsProvider),
                    [for (final p in pot.activePlants) p.plant.id],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.editPot,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditPotScreen(pot: pot.pot),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.delete,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  if (await confirmDeletePot(context, ref, pot)) {
                    navigator.pop();
                  }
                },
              ),
            ],
      body: potAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: context.glass.fg),
        ),
        error: (e, _) => Center(
          child: Text(l10n.errorGeneric('$e'),
              style: TextStyle(color: context.glass.fg)),
        ),
        data: (pot) => pot == null
            ? Center(
                child: Text(l10n.noPotsFound,
                    style: TextStyle(color: context.glass.fg)),
              )
            : _PotDetailBody(pot: pot),
      ),
    );
  }
}

class _PotDetailBody extends ConsumerWidget {
  final PotWithPlants pot;

  const _PotDetailBody({required this.pot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final specs = potSpecs(l10n, pot.pot);
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: context.glass.fg,
      side: BorderSide(color: context.glass.tint(0.3)),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        PotGlassCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PotKindBadge(kind: pot.pot.kind),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pot.pot.kind.label(l10n),
                      style: TextStyle(
                          color: context.glass.fg,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                    if (specs != null)
                      Text(specs,
                          style: TextStyle(color: context.glass.fgMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: context.glass.fgMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pot.location?.name ?? l10n.none,
                            style: TextStyle(color: context.glass.fgMuted),
                          ),
                        ),
                      ],
                    ),
                    if (pot.pot.notes != null) ...[
                      const SizedBox(height: 8),
                      Text(pot.pot.notes!,
                          style: TextStyle(color: context.glass.fg)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              style: buttonStyle,
              onPressed: () => movePotToLocation(context, ref, pot),
              icon: const Icon(Icons.place_outlined),
              label: Text(l10n.movePotToLocation),
            ),
            if (pot.plants.isNotEmpty)
              OutlinedButton.icon(
                style: buttonStyle,
                onPressed: () => moveAllPlantsOfPot(context, ref, pot),
                icon: const Icon(Icons.move_up),
                label: Text(l10n.moveAllPlantsTo),
              ),
          ],
        ),
        const SizedBox(height: 16),
        PotGlassCard(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.potPlantsTitle} (${pot.plants.length})',
                style: TextStyle(
                  color: context.glass.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (pot.plants.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.potEmptyHint,
                      style: TextStyle(color: context.glass.fgMuted)),
                ),
              for (final p in pot.plants) _PotPlantRow(plant: p, pot: pot),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final ids = await showPlantsForPotPicker(context, pot.pot);
                    if (ids == null || ids.isEmpty || !context.mounted) return;
                    await ref
                        .read(potMutationsProvider)
                        .movePlants(ids, pot.pot.id);
                  },
                  icon: Icon(Icons.add, color: context.glass.fg),
                  label: Text(
                    l10n.addPlantsToPot,
                    style: TextStyle(
                      color: context.glass.fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _PlantAction { move, remove }

class _PotPlantRow extends ConsumerWidget {
  final PlantWithSpecies plant;
  final PotWithPlants pot;

  const _PotPlantRow({required this.plant, required this.pot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = plant.plant;
    final subtitle = [
      plant.species.popularName,
      if (!p.isActive) p.status.label(l10n),
    ].join(' · ');
    final tile = ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.local_florist_outlined, color: context.glass.fgMuted),
      title: Text(
        p.nickname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: context.glass.fg, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.glass.fgMuted)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: p.id)),
      ),
      trailing: PopupMenuButton<_PlantAction>(
        icon: Icon(Icons.more_vert, color: context.glass.fgMuted),
        color: context.glass.menu,
        onSelected: (action) => switch (action) {
          _PlantAction.move => pickPotAndMovePlants(context, ref, [p.id],
              currentPotId: pot.pot.id, title: l10n.movePlantToOtherPot),
          _PlantAction.remove => removePlantsFromPot(context, ref, [p.id]),
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _PlantAction.move,
            child: Text(l10n.movePlantToOtherPot),
          ),
          PopupMenuItem(
            value: _PlantAction.remove,
            child: Text(l10n.removePlantFromPot),
          ),
        ],
      ),
    );
    return Material(type: MaterialType.transparency, child: tile);
  }
}
