import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../entries/domain/entry_model.dart';
import 'insight_chart_helpers.dart';
import 'insight_palette.dart';

/// Health score (1–5) over time, with care/problem markers.
class HealthChart extends StatelessWidget {
  final List<EntryModel> points;
  final List<EntryModel> events;
  final InsightPalette palette;

  const HealthChart({
    super.key,
    required this.points,
    required this.events,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final l10n = context.l10n;
    final spots = [
      for (final e in points)
        FlSpot(e.date.millisecondsSinceEpoch.toDouble(), e.numericValue!),
    ];

    var minX = spots.first.x;
    var maxX = spots.last.x;
    if (maxX - minX < 1) {
      minX -= Duration.millisecondsPerDay / 2;
      maxX += Duration.millisecondsPerDay / 2;
    }
    final padX = (maxX - minX) * 0.05;
    minX -= padX;
    maxX += padX;

    final markers = chartEventLines(events, minX, maxX, palette);

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0.6,
          maxY: markers.isEmpty ? 5.4 : 5.9,
          gridData: chartHairlineGrid(palette, 1),
          titlesData: chartTitles(
            palette,
            locale: locale,
            xInterval: (maxX - minX) / 3.2,
            yInterval: 1,
            leftLabel: (v) => v >= 1 && v <= 5 && v % 1 == 0
                ? healthScoreEmoji(v.toInt())
                : null,
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(verticalLines: markers),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => palette.tooltipBg,
              tooltipBorderRadius: BorderRadius.circular(10),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${l10n.healthSummary(s.y.toInt())}\n',
                    TextStyle(
                      color: palette.tooltipInk,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat.yMd(locale).format(
                          DateTime.fromMillisecondsSinceEpoch(s.x.toInt()),
                        ),
                        style: TextStyle(
                          color: palette.tooltipInk.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: palette.health,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: chartDots(palette, palette.health),
              belowBarData: BarAreaData(
                show: true,
                color: palette.health.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
