import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/plant_model.dart';

/// Charts view of the plant detail screen: growth, health and watering
/// regularity, derived from the plant's entries.
class PlantInsightsView extends ConsumerWidget {
  final List<EntryModel> entries;
  final PlantWithSpecies? pws;

  const PlantInsightsView({super.key, required this.entries, this.pws});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final palette = _InsightPalette.of(context, transparent);
    final l10n = context.l10n;

    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    final heights = sorted
        .where((e) => e.type == EntryType.height && e.numericValue != null)
        .toList();
    final healths = sorted
        .where((e) =>
            e.type == EntryType.observation &&
            e.numericValue != null &&
            e.numericValue! >= 1 &&
            e.numericValue! <= 5)
        .toList();
    final waterings =
        sorted.where((e) => e.type == EntryType.irrigation).toList();
    final careEvents = sorted
        .where((e) =>
            e.type == EntryType.fertilizer || e.type == EntryType.pruning)
        .toList();
    // Pest/chlorosis onsets also matter for the health trend (null severity
    // counts as active, matching plantAlertStatusProvider).
    final healthEvents = sorted
        .where((e) =>
            e.type == EntryType.fertilizer ||
            e.type == EntryType.pruning ||
            ((e.type == EntryType.pest || e.type == EntryType.chlorosis) &&
                (e.numericValue ?? 1) > 0))
        .toList();

    final intervals = _wateringIntervals(waterings);

    final hasAnyChart =
        heights.length >= 2 || healths.length >= 2 || intervals.isNotEmpty;

    if (!hasAnyChart) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Text(
            l10n.chartsEmpty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ),
      );
    }

    final lastHeight = heights.isNotEmpty ? heights.last.numericValue! : null;
    final lastHealth =
        healths.isNotEmpty ? healths.last.numericValue!.toInt() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _InsightCard(
            title: l10n.chartGrowthTitle,
            stat: lastHeight != null ? '${_fmtNum(lastHeight)} cm' : null,
            caption: heights.length >= 2
                ? _eventsCaption(l10n, careEvents, heights)
                : null,
            transparent: transparent,
            palette: palette,
            child: heights.length >= 2
                ? _GrowthChart(
                    points: heights,
                    events: careEvents,
                    palette: palette,
                  )
                : _HintText(l10n.chartNeedTwoHeights, palette: palette),
          ),
          _InsightCard(
            title: l10n.chartHealthTitle,
            stat: lastHealth != null
                ? '${_healthEmoji(lastHealth)} ${l10n.healthSummary(lastHealth)}'
                : null,
            caption: healths.length >= 2
                ? _eventsCaption(l10n, healthEvents, healths)
                : null,
            transparent: transparent,
            palette: palette,
            child: healths.length >= 2
                ? _HealthChart(
                    points: healths,
                    events: healthEvents,
                    palette: palette,
                  )
                : _HintText(l10n.chartNeedTwoHealth, palette: palette),
          ),
          _InsightCard(
            title: l10n.chartWateringTitle,
            caption: intervals.isNotEmpty
                ? _wateringCaption(l10n, intervals)
                : null,
            transparent: transparent,
            palette: palette,
            child: intervals.isNotEmpty
                ? _WateringChart(
                    intervals: intervals,
                    idealDays: pws?.effectiveFrequencyDays,
                    palette: palette,
                  )
                : _HintText(l10n.chartNeedTwoWaterings, palette: palette),
          ),
        ],
      ),
    );
  }

  /// Days between consecutive waterings; same-day repeats are skipped.
  /// Keeps the most recent 15 intervals, each tagged with the date of the
  /// later watering.
  List<({DateTime date, int days})> _wateringIntervals(
      List<EntryModel> waterings) {
    final ivs = <({DateTime date, int days})>[];
    for (var i = 1; i < waterings.length; i++) {
      final days =
          waterings[i].date.difference(waterings[i - 1].date).inDays;
      if (days > 0) ivs.add((date: waterings[i].date, days: days));
    }
    return ivs.length > 15 ? ivs.sublist(ivs.length - 15) : ivs;
  }

  String _wateringCaption(
      AppLocalizations l10n, List<({DateTime date, int days})> intervals) {
    final avg =
        intervals.map((e) => e.days).reduce((a, b) => a + b) /
            intervals.length;
    final ideal = pws?.effectiveFrequencyDays;
    return ideal != null
        ? l10n.chartWateringSummary(_fmtNum(avg), ideal)
        : l10n.chartWateringAvgOnly(_fmtNum(avg));
  }

  /// Key line for the event markers actually visible in the chart's window.
  String? _eventsCaption(AppLocalizations l10n, List<EntryModel> events,
      List<EntryModel> points) {
    final start = points.first.date;
    final end = points.last.date;
    final present = events
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .map((e) => e.type)
        .toSet();
    if (present.isEmpty) return null;
    return present.map((t) => '${t.emoji} ${t.label(l10n)}').join('   ');
  }
}

class _HintText extends StatelessWidget {
  final String text;
  final _InsightPalette palette;

  const _HintText(this.text, {required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(color: palette.inkSoft, fontSize: 12.5, height: 1.4),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String? stat;
  final String? caption;
  final Widget child;
  final bool transparent;
  final _InsightPalette palette;

  const _InsightCard({
    required this.title,
    this.stat,
    this.caption,
    required this.child,
    required this.transparent,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparent
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transparent
                  ? Colors.black.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: transparent
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    if (stat != null)
                      Text(
                        stat!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: palette.ink,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
                if (caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    caption!,
                    style: TextStyle(fontSize: 11.5, color: palette.inkSoft),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Height (cm) over time, with fertilizer/pruning markers.
class _GrowthChart extends StatelessWidget {
  final List<EntryModel> points;
  final List<EntryModel> events;
  final _InsightPalette palette;

  const _GrowthChart({
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
    final yInterval = _niceInterval(math.max(maxV - minV, maxV * 0.15));
    final minY =
        math.max(0.0, ((minV / yInterval).floor() - 0.5) * yInterval);
    final markers = _eventLines(events, minX, maxX, palette);
    // Extra headroom so the emoji markers don't sit on the line.
    final maxY = ((maxV / yInterval).ceil() +
            (markers.isEmpty ? 0.5 : 1.0)) *
        yInterval;

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: _hairlineGrid(palette, yInterval),
          titlesData: _titles(
            palette,
            locale: locale,
            xInterval: (maxX - minX) / 3.2,
            yInterval: yInterval,
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(verticalLines: markers),
          lineTouchData: _lineTouch(palette, locale, unit: 'cm'),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: palette.growth,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: _dots(palette, palette.growth),
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

/// Health score (1–5) over time, with care/problem markers.
class _HealthChart extends StatelessWidget {
  final List<EntryModel> points;
  final List<EntryModel> events;
  final _InsightPalette palette;

  const _HealthChart({
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

    final markers = _eventLines(events, minX, maxX, palette);

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0.6,
          maxY: markers.isEmpty ? 5.4 : 5.9,
          gridData: _hairlineGrid(palette, 1),
          titlesData: _titles(
            palette,
            locale: locale,
            xInterval: (maxX - minX) / 3.2,
            yInterval: 1,
            leftLabel: (v) => v >= 1 && v <= 5 && v % 1 == 0
                ? _healthEmoji(v.toInt())
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
              dotData: _dots(palette, palette.health),
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

/// Days between consecutive waterings, against the ideal frequency.
class _WateringChart extends StatelessWidget {
  final List<({DateTime date, int days})> intervals;
  final int? idealDays;
  final _InsightPalette palette;

  const _WateringChart({
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
    final yInterval = _niceInterval(maxData);
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
          gridData: _hairlineGrid(palette, yInterval),
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
                    _fmtNum(value),
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
                    text: DateFormat.yMd(locale)
                        .format(intervals[group.x].date),
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

// ---------------------------------------------------------------------------
// Shared chart pieces
// ---------------------------------------------------------------------------

FlGridData _hairlineGrid(_InsightPalette palette, double yInterval) =>
    FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: yInterval,
      getDrawingHorizontalLine: (_) => FlLine(
        color: palette.grid,
        strokeWidth: 1,
      ),
    );

FlDotData _dots(_InsightPalette palette, Color color) => FlDotData(
      show: true,
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: 4,
        color: color,
        strokeWidth: 2,
        strokeColor: palette.ring,
      ),
    );

FlTitlesData _titles(
  _InsightPalette palette, {
  required String locale,
  required double xInterval,
  required double yInterval,
  String? Function(double value)? leftLabel,
}) =>
    FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          interval: yInterval,
          getTitlesWidget: (value, meta) {
            final text =
                leftLabel != null ? leftLabel(value) : _fmtNum(value);
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

LineTouchData _lineTouch(
  _InsightPalette palette,
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
              '${_fmtNum(s.y)} $unit\n',
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

List<VerticalLine> _eventLines(
  List<EntryModel> events,
  double minX,
  double maxX,
  _InsightPalette palette,
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

String _fmtNum(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

String _healthEmoji(int score) => switch (score) {
      1 => '🔴',
      2 => '🟠',
      3 => '🟡',
      4 => '🟢',
      5 => '💚',
      _ => '',
    };

/// Chart colors resolved for the current surface. Series hues come from the
/// validated data-viz palette (light/dark steps); ink and grid follow the
/// glassmorphism or Material surface the card renders on.
class _InsightPalette {
  final Color growth;
  final Color health;
  final Color water;
  final Color ink;
  final Color inkSoft;
  final Color grid;
  final Color ring;
  final Color tooltipBg;
  final Color tooltipInk;

  const _InsightPalette({
    required this.growth,
    required this.health,
    required this.water,
    required this.ink,
    required this.inkSoft,
    required this.grid,
    required this.ring,
    required this.tooltipBg,
    required this.tooltipInk,
  });

  factory _InsightPalette.of(BuildContext context, bool transparent) {
    final scheme = Theme.of(context).colorScheme;
    final dark =
        transparent || Theme.of(context).brightness == Brightness.dark;

    if (transparent) {
      return const _InsightPalette(
        growth: Color(0xFF199E70),
        health: Color(0xFF9085E9),
        water: Color(0xFF3987E5),
        ink: Colors.white,
        inkSoft: Colors.white60,
        grid: Color(0x1AFFFFFF),
        ring: Color(0xFF1A1A19),
        tooltipBg: Color(0xE6262624),
        tooltipInk: Colors.white,
      );
    }

    return _InsightPalette(
      growth: dark ? const Color(0xFF199E70) : const Color(0xFF1BAF7A),
      health: dark ? const Color(0xFF9085E9) : const Color(0xFF4A3AA7),
      water: dark ? const Color(0xFF3987E5) : const Color(0xFF2A78D6),
      ink: scheme.onSurfaceVariant,
      inkSoft: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      grid: scheme.onSurfaceVariant.withValues(alpha: 0.12),
      ring: scheme.surfaceContainerHighest,
      tooltipBg: const Color(0xE6262624),
      tooltipInk: Colors.white,
    );
  }
}

double _niceInterval(double range) {
  if (range <= 0) return 1;
  final rough = range / 3;
  final mag =
      math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  for (final m in const [1.0, 2.0, 2.5, 5.0]) {
    if (rough <= m * mag) return m * mag;
  }
  return 10 * mag;
}
