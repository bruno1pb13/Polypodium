import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/l10n/l10n.dart';
import 'insight_chart_helpers.dart';
import 'insight_palette.dart';

/// Days between consecutive waterings, against the ideal frequency.
class WateringChart extends StatelessWidget {
  final List<({DateTime date, int days})> intervals;
  final int? idealDays;
  final InsightPalette palette;

  const WateringChart({
    super.key,
    required this.intervals,
    required this.idealDays,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final l10n = context.l10n;
    final n = intervals.length;
    final maxData = math.max(
      intervals.map((e) => e.days).reduce(math.max).toDouble(),
      (idealDays ?? 0).toDouble(),
    );
    final yInterval = niceChartInterval(maxData);
    final maxY = ((maxData / yInterval).ceil() + 0.5) * yInterval;
    final barWidth = math.max(4.0, math.min(24.0, 240 / n));
    // Date labels only at the edges and middle to avoid crowding.
    final labeled = <int>{0, if (n > 2) n ~/ 2, n - 1};

    return SizedBox(
      height: 190,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: chartHairlineGrid(palette, yInterval),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: yInterval,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    formatChartNumber(value),
                    style: TextStyle(fontSize: 10, color: palette.inkSoft),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (!labeled.contains(i)) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat.Md(locale).format(intervals[i].date),
                      style: TextStyle(fontSize: 10, color: palette.inkSoft),
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (idealDays != null)
                HorizontalLine(
                  y: idealDays!.toDouble(),
                  color: palette.inkSoft,
                  strokeWidth: 1,
                  dashArray: [4, 3],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 2, bottom: 2),
                    labelResolver: (_) => l10n.chartIdealLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: palette.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => palette.tooltipBg,
              tooltipBorderRadius: BorderRadius.circular(10),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                '${l10n.daysCount(intervals[group.x].days)}\n',
                TextStyle(
                  color: palette.tooltipInk,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text:
                        DateFormat.yMd(locale).format(intervals[group.x].date),
                    style: TextStyle(
                      color: palette.tooltipInk.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < n; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: intervals[i].days.toDouble(),
                    color: palette.water,
                    width: barWidth,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
