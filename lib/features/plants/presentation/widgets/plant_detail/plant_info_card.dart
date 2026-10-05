import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../entries/presentation/providers/entries_providers.dart';
import '../../../../settings/presentation/providers/settings_providers.dart';
import '../../../domain/plant_model.dart';
import '../plant_status.dart';

/// Soil, location, acquisition date, watering frequency and the active
/// pest/chlorosis/pesticide statuses of the plant.
class PlantInfoCard extends ConsumerWidget {
  final PlantModel plant;
  final PlantWithSpecies? pws;
  final String? soilName;
  final String? soilComposition;

  const PlantInfoCard(
      {super.key,
      required this.plant,
      required this.pws,
      this.soilName,
      this.soilComposition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final alertStatus =
        ref.watch(plantAlertStatusProvider(plant.id)).value ?? noPlantAlerts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? Colors.black.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: transparencyEnabled
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                _row(
                  context,
                  Icons.terrain_outlined,
                  context.l10n.soilLabel,
                  soilName ?? context.l10n.notInformed,
                  transparencyEnabled,
                ),
                if (soilComposition != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        soilComposition!,
                        style: TextStyle(
                          fontSize: 12,
                          color: transparencyEnabled
                              ? Colors.white54
                              : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
                const Divider(color: Colors.white10, height: 16),
                _row(
                  context,
                  Icons.location_on_outlined,
                  context.l10n.locationLabel,
                  pws?.location?.name ??
                      plant.location ??
                      context.l10n.notInformed,
                  transparencyEnabled,
                ),
                const Divider(color: Colors.white10, height: 16),
                _row(
                  context,
                  Icons.calendar_today_outlined,
                  context.l10n.acquiredOnLabel,
                  DateFormat.yMd(context.l10n.localeName)
                      .format(plant.acquisitionDate),
                  transparencyEnabled,
                ),
                if (pws?.effectiveFrequencyDays != null) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _row(
                    context,
                    Icons.opacity_outlined,
                    context.l10n.irrigationFrequencyShort,
                    context.l10n.daysCount(pws!.effectiveFrequencyDays!),
                    transparencyEnabled,
                  ),
                ],
                if (alertStatus.hasActivePest) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _statusRow(
                    context,
                    EntryType.pest,
                    context.l10n.pestBadge,
                    PlantStatusChip(
                      label: _severityLabel(context, alertStatus.pestSeverity),
                      tone: StatusTone.forSeverity(alertStatus.pestSeverity),
                    ),
                    transparencyEnabled,
                  ),
                ],
                if (alertStatus.hasActiveChlorosis) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _statusRow(
                    context,
                    EntryType.chlorosis,
                    context.l10n.entryTypeChlorosis,
                    PlantStatusChip(
                      label: _severityLabel(
                          context, alertStatus.chlorosisSeverity),
                      tone:
                          StatusTone.forSeverity(alertStatus.chlorosisSeverity),
                    ),
                    transparencyEnabled,
                  ),
                ],
                if (pws != null &&
                    (pws!.pesticideUnderActiveControl ||
                        pws!.needsPesticideReapplication)) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _statusRow(
                    context,
                    EntryType.pesticide,
                    context.l10n.entryTypePesticide,
                    pws!.needsPesticideReapplication
                        ? PlantStatusChip(
                            label: context.l10n.pesticideReapplyBadge,
                            tone: StatusTone.danger,
                          )
                        : PlantStatusChip(
                            label: context.l10n.pesticideActiveControlBadge,
                            tone: StatusTone.positive,
                          ),
                    transparencyEnabled,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool transparencyEnabled,
  ) =>
      Row(
        children: [
          Icon(icon,
              size: 20, color: transparencyEnabled ? Colors.white60 : null),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: transparencyEnabled ? Colors.white70 : null)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: transparencyEnabled ? Colors.white : null)),
        ],
      );

  String _severityLabel(BuildContext context, int? v) => switch (v) {
        1 => context.l10n.severityMild,
        2 => context.l10n.severityModerate,
        3 => context.l10n.severitySevere,
        _ => context.l10n.severityActive,
      };

  Widget _statusRow(
    BuildContext context,
    EntryType type,
    String label,
    Widget chip,
    bool transparencyEnabled,
  ) =>
      Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              type.emoji,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: transparencyEnabled ? Colors.white70 : null)),
          const Spacer(),
          chip,
        ],
      );
}
