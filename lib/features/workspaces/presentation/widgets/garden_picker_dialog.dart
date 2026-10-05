import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/garden.dart';

/// How a garden is shown: its name, or for an unnamed personal garden,
/// whose it is.
String gardenDisplayName(Garden garden, AppLocalizations l10n) {
  if (garden.name.isNotEmpty) return garden.name;
  if (garden.isOwnPersonal || garden.ownerEmail == null) {
    return l10n.gardenPersonal;
  }
  return l10n.gardenOf(garden.ownerEmail!);
}

/// What a workspace stores for [garden]: nothing for the account's own
/// personal garden (synced without naming it, as before gardens existed).
GardenChoice? gardenChoiceFor(Garden garden, AppLocalizations l10n) =>
    garden.isOwnPersonal
        ? null
        : (id: garden.id, name: gardenDisplayName(garden, l10n));

/// Lets the user pick one of the account's gardens. Pops the chosen
/// [Garden], or null when dismissed.
class GardenPickerDialog extends StatelessWidget {
  const GardenPickerDialog({super.key, required this.gardens});

  final List<Garden> gardens;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.pickGardenTitle),
      contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.pickGardenBody),
            ),
            for (final garden in gardens)
              ListTile(
                leading: Icon(garden.personal
                    ? Icons.person_outline
                    : Icons.groups_outlined),
                title: Text(gardenDisplayName(garden, l10n)),
                subtitle: Text(garden.isOwner
                    ? l10n.gardenRoleOwner
                    : l10n.gardenRoleMember),
                onTap: () => Navigator.pop(context, garden),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
