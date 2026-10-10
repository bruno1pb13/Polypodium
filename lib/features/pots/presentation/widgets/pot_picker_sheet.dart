import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../domain/pot_model.dart';
import '../../domain/pot_with_plants.dart';
import '../providers/pots_providers.dart';
import '../providers/pots_search_providers.dart';
import '../screens/add_edit_pot_screen.dart';
import 'pot_ui.dart';

/// What was picked in a [PotPickerSheet]: a pot, or no pot ([pot] null).
class PotChoice {
  final PotModel? pot;

  const PotChoice(this.pot);
}

/// Opens the pot picker. Returns null when dismissed. "New pot…" opens the
/// pot form prefilled with [newPotDefaults] and picks the saved pot.
Future<PotChoice?> showPotPicker(
  BuildContext context, {
  String? currentPotId,
  String? title,
  bool allowNone = true,
  Set<String> excludePotIds = const {},
  PotModel? newPotDefaults,
}) =>
    showModalBottomSheet<PotChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PotPickerSheet(
        currentPotId: currentPotId,
        title: title,
        allowNone: allowNone,
        excludePotIds: excludePotIds,
        newPotDefaults: newPotDefaults,
      ),
    );

/// List of pots with search, "No pot" and "New pot…".
class PotPickerSheet extends ConsumerStatefulWidget {
  final String? currentPotId;
  final String? title;
  final bool allowNone;
  final Set<String> excludePotIds;
  final PotModel? newPotDefaults;

  const PotPickerSheet({
    super.key,
    this.currentPotId,
    this.title,
    this.allowNone = true,
    this.excludePotIds = const {},
    this.newPotDefaults,
  });

  @override
  ConsumerState<PotPickerSheet> createState() => _PotPickerSheetState();
}

class _PotPickerSheetState extends ConsumerState<PotPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createPot() async {
    final navigator = Navigator.of(context);
    final pot = await navigator.push<PotModel>(
      MaterialPageRoute(
        builder: (_) => AddEditPotScreen(defaults: widget.newPotDefaults),
      ),
    );
    if (pot != null && mounted) navigator.pop(PotChoice(pot));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final potsAsync = ref.watch(potsWithPlantsProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PotSheetFrame(
      title: widget.title ?? l10n.choosePotTitle,
      child: Column(
        children: [
          AppSearchBar<PotSortOption>(
            controller: _searchController,
            hintText: l10n.searchPotsHint,
            onChanged: (v) => setState(() => _query = v.normalize()),
          ),
          Expanded(
            child: potsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: context.glass.fg),
              ),
              error: (e, _) => Center(
                child: Text(l10n.errorGeneric('$e'),
                    style: TextStyle(color: context.glass.fg)),
              ),
              data: (all) {
                final pots = sortPots(
                  [
                    for (final p in all)
                      if (!widget.excludePotIds.contains(p.pot.id) &&
                          potMatchesQuery(p, _query))
                        p,
                  ],
                  PotSortOption.nameAZ,
                );
                return ListView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
                  children: [
                    if (widget.allowNone && _query.isEmpty)
                      PotPickerTile(
                        leading:
                            Icon(Icons.block, color: context.glass.fgMuted),
                        title: l10n.noPot,
                        selected: widget.currentPotId == null,
                        onTap: () =>
                            Navigator.pop(context, const PotChoice(null)),
                      ),
                    for (final p in pots)
                      _PotTile(
                        pot: p,
                        selected: p.pot.id == widget.currentPotId,
                        onTap: () => Navigator.pop(context, PotChoice(p.pot)),
                      ),
                    if (pots.isEmpty && _query.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.noPotsFound,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.glass.fgMuted),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FilledButton.icon(
                        onPressed: _createPot,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.newPotEllipsis),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.glass.tint(0.1),
                          foregroundColor: context.glass.fg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PotTile extends StatelessWidget {
  final PotWithPlants pot;
  final bool selected;
  final VoidCallback onTap;

  const _PotTile({
    required this.pot,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final specs = potSpecs(l10n, pot.pot);
    final names = pot.plants
        .map((p) => '${p.plant.nickname} #${p.plant.shortCode}')
        .join(', ');
    final subtitle = [
      l10n.potPlantCount(pot.plants.length) + (names.isEmpty ? '' : ': $names'),
      if (pot.location != null) pot.location!.name,
      if (specs != null) specs,
    ].join(' · ');
    return PotPickerTile(
      leading: PotKindBadge(kind: pot.pot.kind, size: 40),
      title: pot.pot.name,
      subtitle: subtitle,
      selected: selected,
      onTap: onTap,
    );
  }
}
