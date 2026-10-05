import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../providers/carencia_providers.dart';

/// Asks before recording a harvest of plants still in carência. [bulk] lists
/// each affected plant by name. True when the user confirms.
Future<bool> confirmHarvestDuringCarencia(
  BuildContext context,
  List<PlantCarencia> affected, {
  required bool bulk,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final l10n = ctx.l10n;
      final dateFmt = DateFormat.Md(l10n.localeName);
      String? productsLine(PlantCarencia p) => p.status.productNames.isEmpty
          ? null
          : l10n.carenciaProductsLine(p.status.productNames.join(', '));

      final paragraphs = <String>[
        if (!bulk) ...[
          l10n.harvestCarenciaDialogBody(
              dateFmt.format(affected.single.status.until)),
          if (productsLine(affected.single) case final line?) line,
        ] else ...[
          l10n.harvestCarenciaDialogBulkBody(affected.length),
          for (final p in affected)
            [
              '• ${l10n.harvestCarenciaPlantLine(p.plantName, dateFmt.format(p.status.until))}',
              if (productsLine(p) case final line?) '  $line',
            ].join('\n'),
        ],
        l10n.harvestCarenciaQuestion,
      ];

      return AlertDialog(
        title: Text(l10n.harvestCarenciaDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, text) in paragraphs.indexed) ...[
                if (i > 0) const SizedBox(height: 12),
                Text(text),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.harvestCarenciaConfirm),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
