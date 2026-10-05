import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../plants/presentation/screens/plant_detail_screen.dart';
import '../../../plants/presentation/widgets/plant_status.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/agenda_task.dart';
import '../providers/agenda_providers.dart';

/// Pending care of every active plant: overdue, due today and coming up in
/// the next [agendaHorizonDays] days, with quick actions per task.
class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(agendaTasksProvider);
    final dueIrrigation = (tasksAsync.value ?? const <AgendaTask>[])
        .where((t) => t.isDue && t.kind == AgendaTaskKind.irrigation)
        .map((t) => t.plant.plant.id)
        .toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          context.l10n.navAgenda,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
        actions: [
          if (dueIrrigation.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.water_drop_outlined),
              tooltip: context.l10n.waterAll,
              onPressed: () => _waterAll(context, ref, dueIrrigation),
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
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: tasksAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.errorGeneric('$e'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (tasks) {
                if (tasks.isEmpty) return const _EmptyState();
                final rows = _rows(context, tasks);
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: rows.length,
                  itemBuilder: (ctx, i) => rows[i],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Section headers interleaved with the task rows. Tasks arrive sorted,
  /// so each section (and each upcoming day) is a contiguous run.
  List<Widget> _rows(BuildContext context, List<AgendaTask> tasks) {
    final l10n = context.l10n;
    final dayFormat = DateFormat.MEd(l10n.localeName);
    final rows = <Widget>[];
    AgendaBucket? bucket;
    DateTime? day;
    for (final task in tasks) {
      if (task.bucket != bucket) {
        bucket = task.bucket;
        final count = tasks.where((t) => t.bucket == bucket).length;
        rows.add(_SectionHeader(
          title: switch (bucket) {
            AgendaBucket.overdue => l10n.agendaOverdue,
            AgendaBucket.today => l10n.agendaToday,
            AgendaBucket.upcoming => l10n.agendaNextDays(agendaHorizonDays),
          },
          count: count,
        ));
      }
      if (bucket == AgendaBucket.upcoming && task.dueDate != day) {
        day = task.dueDate;
        rows.add(_DayHeader(
          title: task.daysRelative == -1
              ? l10n.agendaTomorrow
              : dayFormat.format(task.dueDate),
        ));
      }
      rows.add(_AgendaTaskItem(
        key: ValueKey(
            '${task.plant.plant.id}-${task.kind.name}-${task.entryType.name}'),
        task: task,
      ));
    }
    return rows;
  }
}

Future<void> _waterAll(
    BuildContext context, WidgetRef ref, List<String> plantIds) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await ref.read(entryMutationsProvider).recordIrrigation(plantIds);
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Semantics(
        header: true,
        child: Text(
          '$title ($count)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String title;

  const _DayHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
        ),
      ),
    );
  }
}

class _AgendaTaskItem extends ConsumerWidget {
  final AgendaTask task;

  const _AgendaTaskItem({super.key, required this.task});

  Future<void> _water(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(entryMutationsProvider)
          .recordIrrigation([task.plant.plant.id]);
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.irrigationRecorded),
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
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final pws = task.plant;
    final isIrrigation = task.kind == AgendaTaskKind.irrigation;
    final taskLabel = task.kind == AgendaTaskKind.pesticide
        ? l10n.agendaPesticideTask
        : task.entryType.label(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? Colors.black.withValues(alpha: 0.35)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: transparencyEnabled
                  ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                  : Border.all(color: Colors.transparent),
            ),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantDetailScreen(plantId: pws.plant.id),
                ),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: transparencyEnabled
                            ? Colors.white.withValues(alpha: 0.1)
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // The task label below already names the type.
                      child: ExcludeSemantics(
                        child: Text(
                          task.entryType.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pws.plant.nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: transparencyEnabled
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                              shadows: transparencyEnabled
                                  ? [
                                      const Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$taskLabel'
                            '${pws.location != null ? ' • ${pws.location!.name}' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: transparencyEnabled
                                  ? Colors.white70
                                  : colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                          if (task.bucket == AgendaBucket.overdue) ...[
                            const SizedBox(height: 6),
                            PlantStatusChip(
                              label: l10n.reminderOverdue(task.daysRelative),
                              tone: StatusTone.danger,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Capped so large text sizes wrap the label instead of
                    // squeezing the plant name out.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.4,
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: transparencyEnabled
                              ? Colors.white
                              : colorScheme.primary,
                        ),
                        onPressed: isIrrigation
                            ? () => _water(context, ref)
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEntryScreen(
                                      plantId: pws.plant.id,
                                      initialType: task.entryType,
                                    ),
                                  ),
                                ),
                        child: Text(isIrrigation
                            ? l10n.notificationActionWatered
                            : l10n.agendaRecord),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.agendaAllCaughtUp,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.agendaAllCaughtUpHint(agendaHorizonDays),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
