import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../agenda/domain/agenda_task.dart';
import '../../../agenda/presentation/screens/agenda_screen.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../plants/presentation/screens/plant_detail_screen.dart';
import '../../../plants/presentation/widgets/plant_status.dart';
import '../../domain/garden_overview.dart';
import 'dashboard_card.dart';

/// How many due tasks the today card lists before "+N tarefas".
const _tasksShown = 4;

/// Overdue and due-today care, with a quick watering action.
class DashboardTodayCard extends ConsumerWidget {
  final GardenOverview overview;

  const DashboardTodayCard({super.key, required this.overview});

  Future<void> _water(
      BuildContext context, WidgetRef ref, List<String> plantIds) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(entryMutationsProvider).recordIrrigation(plantIds);
      messenger.showSnackBar(SnackBar(
        content: Text(plantIds.length == 1
            ? l10n.irrigationRecorded
            : l10n.irrigationRecordedForPlants(plantIds.length)),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.irrigationRecordError('$e')),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);
    final tasks = overview.dueTasks;
    final dueIrrigation = [
      for (final t in tasks)
        if (t.kind == AgendaTaskKind.irrigation) t.plant.plant.id,
    ];

    return DashboardCard(
      title: l10n.dashboardTodayTitle,
      trailing: DashboardCardAction(
        label: l10n.dashboardSeeAgenda,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AgendaScreen()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tasks.isEmpty)
            Row(
              children: [
                const ExcludeSemantics(
                    child: Text('✅', style: TextStyle(fontSize: 20))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.dashboardNothingDue,
                    style: TextStyle(color: palette.ink, fontSize: 14),
                  ),
                ),
              ],
            )
          else
            for (final task in tasks.take(_tasksShown))
              _TaskRow(
                task: task,
                onWater: () => _water(context, ref, [task.plant.plant.id]),
              ),
          if (tasks.length > _tasksShown)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.dashboardMoreTasks(tasks.length - _tasksShown),
                style: TextStyle(fontSize: 12.5, color: palette.inkSoft),
              ),
            ),
          if (overview.upcomingCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.dashboardUpcoming(overview.upcomingCount),
                style: TextStyle(fontSize: 12.5, color: palette.inkSoft),
              ),
            ),
          if (dueIrrigation.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.water_drop_outlined),
                label: Text('${l10n.waterAll} (${dueIrrigation.length})'),
                onPressed: () => _water(context, ref, dueIrrigation),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  final AgendaTask task;
  final VoidCallback onWater;

  const _TaskRow({required this.task, required this.onWater});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);
    final plant = task.plant.plant;
    final isIrrigation = task.kind == AgendaTaskKind.irrigation;
    final taskLabel = task.kind == AgendaTaskKind.pesticide
        ? l10n.agendaPesticideTask
        : task.entryType.label(l10n);
    final overdue = task.bucket == AgendaBucket.overdue;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: plant.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (overdue ? StatusTone.danger : StatusTone.warning)
                    .base
                    .withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExcludeSemantics(
                child: Text(task.entryType.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: palette.ink,
                    ),
                  ),
                  Text(
                    overdue
                        ? '$taskLabel • ${l10n.reminderOverdue(task.daysRelative)}'
                        : taskLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: overdue
                          ? StatusTone.danger.foreground(context)
                          : palette.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            if (isIrrigation)
              IconButton(
                icon: const Icon(Icons.water_drop_outlined),
                color: palette.water,
                tooltip: l10n.notificationActionWatered,
                onPressed: onWater,
              )
            else
              IconButton(
                icon: const Icon(Icons.playlist_add),
                color: palette.ink,
                tooltip: l10n.agendaRecord,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEntryScreen(
                      plantId: plant.id,
                      initialType: task.entryType,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Share of healthy plants as a ring, next to what the others need.
class DashboardHealthCard extends ConsumerWidget {
  final GardenOverview overview;

  const DashboardHealthCard({super.key, required this.overview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);
    final percent = (overview.healthyRatio * 100).round();
    final issues = [
      (
        emoji: EntryType.irrigation.emoji,
        label: l10n.dashboardNeedWater,
        count: overview.needsWaterCount,
        tone: StatusTone.danger,
      ),
      (
        emoji: EntryType.pest.emoji,
        label: l10n.dashboardWithPests,
        count: overview.pestCount,
        tone: StatusTone.danger,
      ),
      (
        emoji: EntryType.chlorosis.emoji,
        label: l10n.dashboardWithChlorosis,
        count: overview.chlorosisCount,
        tone: StatusTone.warning,
      ),
      (
        emoji: EntryType.pesticide.emoji,
        label: l10n.dashboardPesticideDue,
        count: overview.pesticideDueCount,
        tone: StatusTone.warning,
      ),
    ].where((i) => i.count > 0).toList();

    return DashboardCard(
      title: l10n.dashboardHealthTitle,
      child: Row(
        children: [
          Semantics(
            label: l10n.dashboardHealthyLabel(percent),
            excludeSemantics: true,
            child: SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: overview.healthyRatio,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    color: palette.growth,
                    backgroundColor: palette.grid,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percent%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: palette.ink,
                            ),
                          ),
                          Text(
                            l10n.dashboardHealthy,
                            style:
                                TextStyle(fontSize: 11, color: palette.inkSoft),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: issues.isEmpty
                ? Text(
                    '🌿 ${l10n.dashboardAllHealthy}',
                    style: TextStyle(color: palette.ink, fontSize: 14),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final issue in issues)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              ExcludeSemantics(
                                child: Text(issue.emoji,
                                    style: const TextStyle(fontSize: 14)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  issue.label,
                                  style: TextStyle(
                                      fontSize: 13, color: palette.ink),
                                ),
                              ),
                              Text(
                                '${issue.count}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: issue.tone.foreground(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
