import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../dashboard/presentation/widgets/dashboard_card.dart';
import '../../../plants/presentation/widgets/insights/insight_palette.dart';
import '../../domain/garden_activity.dart';

const _gap = 3.0;
const _minCell = 9.0;
const _maxCell = 22.0;
const _monthRowHeight = 16.0;
const _weekdayColumnWidth = 30.0;

/// GitHub-style heatmap of the range: one square per day, in week columns,
/// greener the more entries were logged that day.
class ActivityHeatmapCard extends ConsumerWidget {
  final GardenActivity activity;

  const ActivityHeatmapCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);

    return DashboardCard(
      title: l10n.activityHeatmapTitle(activity.totalEntries),
      trailing: activity.streakDays > 1
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_outlined,
                    size: 16, color: palette.ink),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.activityStreak(activity.streakDays),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                ),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            label: l10n.activityHeatmapLabel(activity.totalEntries,
                activity.activeDays, activity.heatmap.length),
            child: ExcludeSemantics(
              child: _Heatmap(days: activity.heatmap, palette: palette),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _Legend(palette: palette),
          ),
        ],
      ),
    );
  }
}

/// Fill of a heatmap square of [level] (0 = no entries).
Color _levelColor(InsightPalette palette, int level) => level == 0
    ? palette.ink.withValues(alpha: 0.08)
    : palette.growth.withValues(alpha: const [0.3, 0.5, 0.75, 1.0][level - 1]);

class _Heatmap extends StatelessWidget {
  final List<DayActivity> days;
  final InsightPalette palette;

  const _Heatmap({required this.days, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    // Row of a day in its week column, 0 = the locale's first weekday.
    int rowOf(DateTime d) => (d.weekday % 7 - firstWeekday) % 7;

    final first = days.first.day;
    final gridStart =
        DateTime(first.year, first.month, first.day - rowOf(first));
    int indexOf(DateTime d) => DateTime.utc(d.year, d.month, d.day)
        .difference(
            DateTime.utc(gridStart.year, gridStart.month, gridStart.day))
        .inDays;
    final weeks = indexOf(days.last.day) ~/ 7 + 1;

    final month = DateFormat.MMM(l10n.localeName);
    final weekday = DateFormat.E(l10n.localeName);
    final dayFormat = DateFormat.yMMMd(l10n.localeName);
    String clean(String s) => s.replaceAll('.', '');

    return LayoutBuilder(builder: (context, constraints) {
      final available = constraints.maxWidth - _weekdayColumnWidth;
      final cell =
          (available / weeks - _gap).clamp(_minCell, _maxCell).toDouble();
      final step = cell + _gap;
      final gridWidth = weeks * step;
      final gridHeight = _monthRowHeight + 7 * step;
      final labelStyle = TextStyle(fontSize: 10, color: palette.inkSoft);

      // A label over the column where each month starts, plus one for the
      // range's first month when the next month's label leaves room for it.
      final monthStarts = [
        for (final d in days)
          if (d.day.day == 1) d.day,
      ];
      final labelled = [
        if (monthStarts.isEmpty ||
            indexOf(monthStarts.first) ~/ 7 - indexOf(first) ~/ 7 >= 3)
          first,
        ...monthStarts,
      ];
      final monthLabels = [
        for (final d in labelled)
          Positioned(
            left: (indexOf(d) ~/ 7) * step,
            top: 0,
            child: Text(clean(month.format(d)), style: labelStyle),
          ),
      ];

      final grid = SizedBox(
        width: gridWidth,
        height: gridHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...monthLabels,
            for (final d in days)
              Positioned(
                left: (indexOf(d.day) ~/ 7) * step,
                top: _monthRowHeight + rowOf(d.day) * step,
                child: Tooltip(
                  message:
                      l10n.activityDayTooltip(d.count, dayFormat.format(d.day)),
                  child: Container(
                    width: cell,
                    height: cell,
                    decoration: BoxDecoration(
                      color: _levelColor(palette, d.level),
                      borderRadius:
                          BorderRadius.circular(math.min(3, cell / 4)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _weekdayColumnWidth,
            height: gridHeight,
            child: Stack(
              children: [
                // Every other weekday, like GitHub, so the labels breathe.
                for (final row in const [1, 3, 5])
                  Positioned(
                    left: 0,
                    top: _monthRowHeight + row * step + (cell - 12) / 2,
                    child: Text(
                      clean(weekday.format(
                          gridStart.add(Duration(days: row, hours: 12)))),
                      style: labelStyle,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: gridWidth <= available
                ? Align(alignment: Alignment.centerLeft, child: grid)
                // Too many weeks to fit: scrolls, starting at today, and
                // mice and trackpads can drag it.
                : ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: PointerDeviceKind.values.toSet(),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: grid,
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

class _Legend extends StatelessWidget {
  final InsightPalette palette;

  const _Legend({required this.palette});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 11, color: palette.inkSoft);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.activityLess, style: style),
        const SizedBox(width: 6),
        for (var level = 0; level <= heatmapLevels; level++)
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(right: _gap),
            decoration: BoxDecoration(
              color: _levelColor(palette, level),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 3),
        Text(context.l10n.activityMore, style: style),
      ],
    );
  }
}
