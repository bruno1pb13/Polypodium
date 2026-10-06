import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../plants/presentation/widgets/insights/insight_chart_helpers.dart';
import '../../../plants/presentation/widgets/insights/insight_palette.dart';
import '../../../dashboard/presentation/widgets/dashboard_card.dart';
import '../../domain/garden_activity.dart';

/// Entries per day of the last [chartDays] days, waterings stacked under
/// the other care, with the logging streak.
class ActivityChartCard extends ConsumerWidget {
  final GardenActivity activity;

  const ActivityChartCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);
    final chart = activity.chart;
    final waterings = chart.fold(0, (sum, d) => sum + d.irrigation);
    final care = chart.fold(0, (sum, d) => sum + d.care);

    return DashboardCard(
      title: l10n.activityChartTitle(chartDays),
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
          if (waterings + care == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.activityChartEmpty,
                style: TextStyle(fontSize: 13, color: palette.inkSoft),
              ),
            )
          else ...[
            Semantics(
              container: true,
              label: l10n.activityChartLabel(waterings, care, chartDays),
              child: ExcludeSemantics(
                child: _ActivityChart(activity: chart, palette: palette),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _Legend(
                    color: palette.water,
                    label: '${l10n.activityWaterings} ($waterings)',
                    palette: palette),
                _Legend(
                    color: palette.growth,
                    label: '${l10n.activityOtherCare} ($care)',
                    palette: palette),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final List<DayActivity> activity;
  final InsightPalette palette;

  const _ActivityChart({required this.activity, required this.palette});

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final weekday = DateFormat.E(locale);
    final dayMonth = DateFormat.Md(locale);
    final maxData = activity.map((d) => d.total).reduce(math.max).toDouble();
    // Whole numbers: these are counts of entries.
    final yInterval = math.max(1.0, niceChartInterval(maxData).ceilToDouble());
    final maxY = (maxData / yInterval).ceil() * yInterval;
    final n = activity.length;

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: chartHairlineGrid(palette, yInterval),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => palette.tooltipBg,
              getTooltipItem: (group, _, __, ___) {
                final day = activity[group.x];
                return BarTooltipItem(
                  '${weekday.format(day.day)} ${dayMonth.format(day.day)}\n'
                  '${context.l10n.activityTooltip(day.irrigation, day.care)}',
                  TextStyle(color: palette.tooltipInk, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
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
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  // Weekly ticks, counted back from today.
                  if ((n - 1 - i) % 7 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      i == n - 1
                          ? context.l10n.agendaToday
                          : dayMonth.format(activity[i].day),
                      style: TextStyle(fontSize: 10, color: palette.inkSoft),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (final (i, day) in activity.indexed)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: day.total.toDouble(),
                    width: 10,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(3)),
                    color: Colors.transparent,
                    rodStackItems: [
                      BarChartRodStackItem(
                          0, day.irrigation.toDouble(), palette.water),
                      BarChartRodStackItem(day.irrigation.toDouble(),
                          day.total.toDouble(), palette.growth),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final InsightPalette palette;

  const _Legend({
    required this.color,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label,
              style: TextStyle(fontSize: 12, color: palette.inkSoft)),
        ),
      ],
    );
  }
}
