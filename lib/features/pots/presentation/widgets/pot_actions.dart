import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../domain/pot_model.dart';
import '../../domain/pot_with_plants.dart';
import '../providers/pots_providers.dart';
import 'pot_picker_sheet.dart';
import 'pot_ui.dart';

/// Records a plain irrigation for each of [plantIds], with a snackbar.
Future<void> waterPotPlants(BuildContext context, EntryMutations mutations,
    List<String> plantIds) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await mutations.recordIrrigation(plantIds);
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

/// Asks to delete [pot], saying how many plants it holds, and deletes it.
/// Returns whether it was deleted.
Future<bool> confirmDeletePot(
    BuildContext context, WidgetRef ref, PotWithPlants pot) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.l10n.deletePotTitle),
      content: Text(ctx.l10n.deletePotBody(pot.plants.length)),
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
  if (confirmed != true) return false;
  await ref.read(potMutationsProvider).delete(pot.pot.id);
  return true;
}

void _showMoved(
    ScaffoldMessengerState messenger, AppLocalizations l10n, int count) {
  messenger.showSnackBar(SnackBar(
    content: Text(l10n.plantsMoved(count)),
    duration: const Duration(seconds: 2),
  ));
}

/// Lets the user pick another pot (or none, or a new one) for the plants
/// [plantIds] and moves them, recording the move in each diary.
Future<void> pickPotAndMovePlants(
  BuildContext context,
  WidgetRef ref,
  List<String> plantIds, {
  String? currentPotId,
  String? title,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final choice =
      await showPotPicker(context, currentPotId: currentPotId, title: title);
  if (choice == null || choice.pot?.id == currentPotId) return;
  final moved =
      await ref.read(potMutationsProvider).movePlants(plantIds, choice.pot?.id);
  _showMoved(messenger, l10n, moved.length);
}

/// Takes the plants [plantIds] out of their pot.
Future<void> removePlantsFromPot(
    BuildContext context, WidgetRef ref, List<String> plantIds) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final moved = await ref.read(potMutationsProvider).movePlants(plantIds, null);
  _showMoved(messenger, l10n, moved.length);
}

/// Picks a target pot for every plant of [pot] and moves them all there.
Future<void> moveAllPlantsOfPot(
    BuildContext context, WidgetRef ref, PotWithPlants pot) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final choice = await showPotPicker(
    context,
    title: l10n.moveAllPlantsTo,
    excludePotIds: {pot.pot.id},
    // A bigger pot of the same kind, typically.
    newPotDefaults: PotModel(
      id: '',
      name: '',
      kind: pot.pot.kind,
      material: pot.pot.material,
      locationId: pot.pot.locationId,
      createdAt: DateTime.now(),
    ),
  );
  if (choice == null) return;
  final moved = await ref
      .read(potMutationsProvider)
      .moveAllPlants(pot.pot.id, choice.pot?.id);
  _showMoved(messenger, l10n, moved.length);
}

/// What was picked in [showLocationPicker]: a location id, or none.
class LocationChoice {
  final String? locationId;

  const LocationChoice(this.locationId);
}

/// Picks a location (or none) from the registered ones.
Future<LocationChoice?> showLocationPicker(BuildContext context,
    {String? currentLocationId}) {
  return showModalBottomSheet<LocationChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final locations =
            ref.watch(locationsNotifierProvider).value ?? const [];
        return PotSheetFrame(
          title: ctx.l10n.chooseLocationTitle,
          heightFactor: 0.6,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              PotPickerTile(
                leading:
                    Icon(Icons.location_off_outlined, color: ctx.glass.fgMuted),
                title: ctx.l10n.none,
                selected: currentLocationId == null,
                onTap: () => Navigator.pop(ctx, const LocationChoice(null)),
              ),
              for (final l in locations)
                PotPickerTile(
                  leading: Icon(Icons.location_on_outlined,
                      color: ctx.glass.fgMuted),
                  title: l.name,
                  subtitle: l.description,
                  selected: l.id == currentLocationId,
                  onTap: () => Navigator.pop(ctx, LocationChoice(l.id)),
                ),
            ],
          ),
        );
      },
    ),
  );
}

/// "Move pot to…": the pot and every plant in it go to the picked location.
Future<void> movePotToLocation(
    BuildContext context, WidgetRef ref, PotWithPlants pot) async {
  final choice =
      await showLocationPicker(context, currentLocationId: pot.pot.locationId);
  if (choice == null || choice.locationId == pot.pot.locationId) return;
  await ref
      .read(potMutationsProvider)
      .moveToLocation(pot.pot.id, choice.locationId);
}
