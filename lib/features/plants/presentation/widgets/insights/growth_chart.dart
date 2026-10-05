import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../entries/domain/entry_model.dart';
import 'insight_chart_helpers.dart';
import 'insight_palette.dart';

/// Height (cm) over time, with fertilizer/pruning markers.
class GrowthChart extends StatelessWidget {
  final List<EntryModel> points;
  final List<EntryModel> events;
  final InsightPalette palette;

  const GrowthChart({
    super.key,
    required this.points,
    required this.events,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
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

    final values = spots.map((s) => s.y);
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final yInterval = niceChartInterval(math.max(maxV - minV, maxV * 0.15));
    final minY = math.max(0.0, ((minV / yInterval).floor() - 0.5) * yInterval);
    final markers = chartEventLines(events, minX, maxX, palette);
    // Extra headroom so the emoji markers don't sit on the line.
    final maxY =
        ((maxV / yInterval).ceil() + (markers.isEmpty ? 0.5 : 1.0)) * yInterval;

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: chartHairlineGrid(palette, yInterval),
          titlesData: chartTitles(
            palette,
            locale: locale,
            xInterval: (maxX - minX) / 3.2,
            yInterval: yInterval,
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(verticalLines: markers),
          lineTouchData: chartLineTouch(palette, locale, unit: 'cm'),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: palette.growth,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: chartDots(palette, palette.growth),
              belowBarData: BarAreaData(
                show: true,
                color: palette.growth.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
