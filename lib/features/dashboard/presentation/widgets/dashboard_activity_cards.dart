import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../plants/presentation/screens/plant_detail_screen.dart';
import '../../../plants/presentation/widgets/insights/insight_chart_helpers.dart';
import '../../../plants/presentation/widgets/insights/insight_palette.dart';
import '../../domain/garden_overview.dart';
import 'dashboard_card.dart';

/// Entries per day of the last [chartDays] days, waterings stacked under
/// the other care, with the logging streak.
class DashboardActivityCard extends ConsumerWidget {
  final GardenOverview overview;

  const DashboardActivityCard({super.key, required this.overview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);
    final activity = overview.activity;
    final waterings = activity.fold(0, (sum, d) => sum + d.irrigation);
    final care = activity.fold(0, (sum, d) => sum + d.care);

    return DashboardCard(
      title: l10n.dashboardActivityTitle,
      trailing: overview.streakDays > 1
          ? Text(
              '🔥 ${l10n.dashboardStreak(overview.streakDays)}',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardLastDays(chartDays),
            style: TextStyle(fontSize: 12, color: palette.inkSoft),
          ),
          const SizedBox(height: 8),
          if (waterings + care == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.dashboardNoActivity,
                style: TextStyle(fontSize: 13, color: palette.inkSoft),
              ),
            )
          else ...[
            Semantics(
              container: true,
              label: l10n.dashboardActivityChartLabel(
                  waterings, care, chartDays),
              child: ExcludeSemantics(
                child: _ActivityChart(activity: activity, palette: palette),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _Legend(
                    color: palette.water,
                    label: '${l10n.dashboardWaterings} ($waterings)',
                    palette: palette),
                _Legend(
                    color: palette.growth,
                    label: '${l10n.dashboardOtherCare} ($care)',
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
                  '💧 ${day.irrigation}   🌱 ${day.care}',
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

/// The newest entries of the whole garden.
class DashboardRecentCard extends ConsumerWidget {
  final GardenOverview overview;

  const DashboardRecentCard({super.key, required this.overview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);
    final dayMonth = DateFormat.MMMd(l10n.localeName);

    String when(DateTime date) => switch (calendarDaysBetween(date)) {
          0 => l10n.agendaToday,
          1 => l10n.dashboardYesterday,
          _ => dayMonth.format(date),
        };

    return DashboardCard(
      title: l10n.dashboardRecentTitle,
      child: Column(
        children: [
          for (final (i, item) in overview.recent.indexed) ...[
            if (i > 0) Divider(height: 1, color: palette.grid),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PlantDetailScreen(plantId: item.plant.plant.id),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Text(item.entry.type.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: item.plant.plant.nickname,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: ' · ${item.entry.type.label(l10n)}',
                            style: TextStyle(color: palette.inkSoft),
                          ),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5, color: palette.ink),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      when(item.entry.date),
                      style: TextStyle(fontSize: 12, color: palette.inkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
