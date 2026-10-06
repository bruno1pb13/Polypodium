import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../domain/garden_overview.dart';

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
