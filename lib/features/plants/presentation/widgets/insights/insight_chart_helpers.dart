import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/enums.dart';
import '../../../../entries/domain/entry_model.dart';
import 'insight_palette.dart';

// ---------------------------------------------------------------------------
// Shared chart pieces
// ---------------------------------------------------------------------------

FlGridData chartHairlineGrid(InsightPalette palette, double yInterval) =>
    FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: yInterval,
      getDrawingHorizontalLine: (_) => FlLine(
        color: palette.grid,
        strokeWidth: 1,
      ),
    );

FlDotData chartDots(InsightPalette palette, Color color) => FlDotData(
      show: true,
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: 4,
        color: color,
        strokeWidth: 2,
        strokeColor: palette.ring,
      ),
    );

FlTitlesData chartTitles(
  InsightPalette palette, {
  required String locale,
  required double xInterval,
  required double yInterval,
  String? Function(double value)? leftLabel,
}) =>
    FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          interval: yInterval,
          getTitlesWidget: (value, meta) {
            final text =
                leftLabel != null ? leftLabel(value) : formatChartNumber(value);
            if (text == null) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                text,
                style: TextStyle(fontSize: 10, color: palette.inkSoft),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          interval: xInterval,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              DateFormat.Md(locale).format(
                DateTime.fromMillisecondsSinceEpoch(value.toInt()),
              ),
              style: TextStyle(fontSize: 10, color: palette.inkSoft),
            ),
          ),
        ),
      ),
    );

LineTouchData chartLineTouch(
  InsightPalette palette,
  String locale, {
  required String unit,
}) =>
    LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => palette.tooltipBg,
        tooltipBorderRadius: BorderRadius.circular(10),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (spots) => [
          for (final s in spots)
            LineTooltipItem(
              '${formatChartNumber(s.y)} $unit\n',
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
    );

List<VerticalLine> chartEventLines(
  List<EntryModel> events,
  double minX,
  double maxX,
  InsightPalette palette,
) =>
    [
      for (final e in events)
        if (e.date.millisecondsSinceEpoch >= minX &&
            e.date.millisecondsSinceEpoch <= maxX)
          VerticalLine(
            x: e.date.millisecondsSinceEpoch.toDouble(),
            color: palette.inkSoft.withValues(alpha: 0.35),
            strokeWidth: 1,
            label: VerticalLineLabel(
              show: true,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.zero,
              style: const TextStyle(fontSize: 11),
              labelResolver: (_) => e.type.emoji,
            ),
          ),
    ];

String formatChartNumber(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

String healthScoreEmoji(int score) => switch (score) {
      1 => '🔴',
      2 => '🟠',
      3 => '🟡',
      4 => '🟢',
      5 => '💚',
      _ => '',
    };

double niceChartInterval(double range) {
  if (range <= 0) return 1;
  final rough = range / 3;
  final mag = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  for (final m in const [1.0, 2.0, 2.5, 5.0]) {
    if (rough <= m * mag) return m * mag;
  }
  return 10 * mag;
}
