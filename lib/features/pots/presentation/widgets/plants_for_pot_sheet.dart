import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../plants/domain/plant_model.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../domain/pot_model.dart';
import 'pot_ui.dart';

/// Whether [p] matches the normalized [query] by nickname, species or short
/// code.
bool plantMatchesPotQuery(PlantWithSpecies p, String query) {
  if (query.isEmpty) return true;
  return p.plant.nickname.normalize().contains(query) ||
      p.species.popularName.normalize().contains(query) ||
      p.species.scientificName.normalize().contains(query) ||
      matchesPlantShortCode(query, p.plant.shortCode);
}

/// Multi-select of the active plants not yet in [pot], each showing the pot
/// it is in now. Returns the picked plant ids (null when dismissed).
Future<List<String>?> showPlantsForPotPicker(
        BuildContext context, PotModel pot) =>
    showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlantsForPotSheet(pot: pot),
    );

class PlantsForPotSheet extends ConsumerStatefulWidget {
  final PotModel pot;

  const PlantsForPotSheet({super.key, required this.pot});

  @override
  ConsumerState<PlantsForPotSheet> createState() => _PlantsForPotSheetState();
}

class _PlantsForPotSheetState extends ConsumerState<PlantsForPotSheet> {
  final _searchController = TextEditingController();
  final _selected = <String>{};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plantsAsync = ref.watch(plantsWithSpeciesProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PotSheetFrame(
      title: l10n.addPlantsToPotTitle(widget.pot.name),
      child: Column(
        children: [
          AppSearchBar<Never>(
            controller: _searchController,
            hintText: l10n.searchPlantsHint,
            onChanged: (v) => setState(() => _query = v.normalize()),
          ),
          Expanded(
            child: plantsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: context.glass.fg),
              ),
              error: (e, _) => Center(
                child: Text(l10n.errorGeneric('$e'),
                    style: TextStyle(color: context.glass.fg)),
              ),
              data: (all) {
                final plants = [
                  for (final p in all)
                    if (p.plant.isActive &&
                        p.plant.potId != widget.pot.id &&
                        plantMatchesPotQuery(p, _query))
                      p,
                ]..sort((a, b) => a.plant.nickname
                    .normalize()
                    .compareTo(b.plant.nickname.normalize()));
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final p in plants)
                      PotPickerTile(
                        leading: Icon(Icons.local_florist_outlined,
                            color: context.glass.fgMuted),
                        title: p.plant.nickname,
                        subtitle: [
                          p.species.popularName,
                          if (p.pot != null)
                            l10n.potPlantPickerOtherPot(p.pot!.name),
                        ].join(' · '),
                        selected: _selected.contains(p.plant.id),
                        trailing: Checkbox(
                          value: _selected.contains(p.plant.id),
                          onChanged: (_) => _toggle(p.plant.id),
                        ),
                        onTap: () => _toggle(p.plant.id),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, _selected.toList()),
                child: Text(l10n.moveHereCount(_selected.length)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });
}
