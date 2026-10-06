import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../domain/garden_overview.dart';
import 'dashboard_card.dart';

/// Greeting for the time of day, today's date and a one-line summary.
class DashboardGreeting extends StatelessWidget {
  final GardenOverview overview;
  final DateTime now;

  const DashboardGreeting({
    super.key,
    required this.overview,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final greeting = now.hour < 12
        ? l10n.dashboardGoodMorning
        : now.hour < 18
            ? l10n.dashboardGoodAfternoon
            : l10n.dashboardGoodEvening;
    final date = toBeginningOfSentenceCase(
        DateFormat.MMMMEEEEd(l10n.localeName).format(now));
    final due = overview.dueTasks.length;
    final shadows = [
      Shadow(color: context.glass.shadow(Colors.black45), blurRadius: 4),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: TextStyle(
              color: context.glass.fgMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 2),
          Semantics(
            header: true,
            child: Text(
              greeting,
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
                fontSize: 34,
                height: 1.1,
                color: context.glass.fg,
                shadows: shadows,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            due > 0
                ? l10n.dashboardSummaryDue(due)
                : l10n.dashboardSummaryClear,
            style: TextStyle(
              color: context.glass.fg,
              fontSize: 15,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

typedef DashboardStat = ({
  IconData icon,
  int value,
  String label,
  VoidCallback? onTap,
});

/// Row (or 2×2 grid, when narrow) of headline numbers.
class DashboardStatTiles extends StatelessWidget {
  final List<DashboardStat> stats;

  const DashboardStatTiles({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final perRow = constraints.maxWidth >= 560 ? stats.length : 2;
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final s in stats)
            SizedBox(width: width, child: _StatTile(stat: s)),
        ],
      );
    });
  }
}

class _StatTile extends ConsumerWidget {
  final DashboardStat stat;

  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = dashboardPalette(context, ref);

    return Semantics(
      button: stat.onTap != null,
      label: '${stat.value} ${stat.label}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: stat.onTap,
        behavior: HitTestBehavior.opaque,
        child: DashboardCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: palette.growth.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, size: 20, color: palette.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stat.value}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: palette.ink,
                      ),
                    ),
                    Text(
                      stat.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: palette.inkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
