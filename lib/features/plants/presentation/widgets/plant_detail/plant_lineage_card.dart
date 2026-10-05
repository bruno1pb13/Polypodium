import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/theme/glass_colors.dart';
import '../../../../settings/presentation/providers/settings_providers.dart';
import '../../../domain/plant_lineage.dart';
import '../../../domain/plant_model.dart';

/// The plant's parent ("cutting of") and its cuttings, each opening that
/// plant, plus the action to create a new cutting of it.
class PlantLineageCard extends ConsumerWidget {
  final PlantModel plant;

  /// Every non-deleted plant, to resolve the parent and the cuttings.
  final List<PlantModel> plants;
  final ValueChanged<String> onOpenPlant;
  final VoidCallback onCreateCutting;

  const PlantLineageCard({
    super.key,
    required this.plant,
    required this.plants,
    required this.onOpenPlant,
    required this.onCreateCutting,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final l10n = context.l10n;
    final parentId = plant.parentPlantId;
    // A parent missing from the list was deleted: its id is kept, but there
    // is nothing left to open.
    final parent = parentId == null
        ? null
        : plants.where((p) => p.id == parentId).firstOrNull;
    final cuttings = cuttingsOf(plant.id, plants);
    final divider = Divider(color: context.glass.divider, height: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparent
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: transparent
                  ? context.glass.scrim(0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    transparent ? context.glass.tint(0.1) : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (parentId != null) ...[
                  _PlantLinkRow(
                    icon: Icons.call_split,
                    label: l10n.parentPlantLabel,
                    value: parent == null
                        ? l10n.parentPlantRemoved
                        : _name(l10n, parent),
                    transparent: transparent,
                    onTap: parent == null ? null : () => onOpenPlant(parent.id),
                  ),
                  divider,
                ],
                if (cuttings.isNotEmpty) ...[
                  _PlantLinkRow(
                    icon: Icons.eco_outlined,
                    label: l10n.cuttingsLabel,
                    value: '${cuttings.length}',
                    transparent: transparent,
                  ),
                  for (final cutting in cuttings)
                    _PlantLinkRow(
                      label: _name(l10n, cutting),
                      transparent: transparent,
                      indent: true,
                      onTap: () => onOpenPlant(cutting.id),
                    ),
                  divider,
                ],
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: onCreateCutting,
                    icon: Icon(Icons.add,
                        color: transparent ? context.glass.fg : null),
                    label: Text(
                      l10n.createCutting,
                      style: TextStyle(
                        color: transparent ? context.glass.fg : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _name(AppLocalizations l10n, PlantModel p) =>
      p.isActive ? p.nickname : '${p.nickname} · ${p.status.label(l10n)}';
}

/// "Label ... value" row; tappable (with a chevron) when [onTap] is set.
class _PlantLinkRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;
  final bool transparent;
  final bool indent;
  final VoidCallback? onTap;

  const _PlantLinkRow({
    this.icon,
    required this.label,
    this.value,
    required this.transparent,
    this.indent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted = transparent ? context.glass.fgMuted : null;
    final strong = transparent ? context.glass.fg : null;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: indent ? 32 : 0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 20, color: transparent ? context.glass.fgSubtle : null),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: value == null ? strong : muted,
                  fontWeight:
                      value == null && onTap != null ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: strong,
                  ),
                ),
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 20, color: transparent ? context.glass.fgSubtle : null),
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Semantics(button: true, child: row),
      ),
    );
  }
}
