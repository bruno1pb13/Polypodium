import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/plant_model.dart';
import 'insights/growth_chart.dart';
import 'insights/health_chart.dart';
import 'insights/insight_card.dart';
import 'insights/insight_chart_helpers.dart';
import 'insights/insight_palette.dart';
import 'insights/watering_chart.dart';

/// Charts view of the plant detail screen: growth, health and watering
/// regularity, derived from the plant's entries.
class PlantInsightsView extends ConsumerWidget {
  final List<EntryModel> entries;
  final PlantWithSpecies? pws;

  const PlantInsightsView({super.key, required this.entries, this.pws});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final palette = InsightPalette.of(context, transparent);
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
            e.type == EntryType.fertilizer ||
            e.type == EntryType.pruning ||
            e.type == EntryType.pesticide)
        .toList();
    // Pest/chlorosis onsets also matter for the health trend (null severity
    // counts as active, matching plantAlertStatusProvider).
    final healthEvents = sorted
        .where((e) =>
            e.type == EntryType.fertilizer ||
            e.type == EntryType.pruning ||
            e.type == EntryType.pesticide ||
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
          InsightCard(
            title: l10n.chartGrowthTitle,
            stat: lastHeight != null
                ? '${formatChartNumber(lastHeight)} cm'
                : null,
            caption: heights.length >= 2
                ? _eventsCaption(l10n, careEvents, heights)
                : null,
            captionLabel: heights.length >= 2
                ? _eventsCaption(l10n, careEvents, heights, spoken: true)
                : null,
            chartLabel: heights.length >= 2
                ? l10n.chartGrowthSemantics(
                    heights.length,
                    formatChartNumber(heights.first.numericValue!),
                    formatChartNumber(lastHeight!),
                  )
                : null,
            transparent: transparent,
            palette: palette,
            child: heights.length >= 2
                ? GrowthChart(
                    points: heights,
                    events: careEvents,
                    palette: palette,
                  )
                : InsightHintText(l10n.chartNeedTwoHeights, palette: palette),
          ),
          InsightCard(
            title: l10n.chartHealthTitle,
            stat: lastHealth != null ? l10n.healthSummary(lastHealth) : null,
            statEmoji: lastHealth != null ? healthScoreEmoji(lastHealth) : null,
            caption: healths.length >= 2
                ? _eventsCaption(l10n, healthEvents, healths)
                : null,
            captionLabel: healths.length >= 2
                ? _eventsCaption(l10n, healthEvents, healths, spoken: true)
                : null,
            chartLabel: healths.length >= 2
                ? l10n.chartHealthSemantics(healths.length, lastHealth!)
                : null,
            transparent: transparent,
            palette: palette,
            child: healths.length >= 2
                ? HealthChart(
                    points: healths,
                    events: healthEvents,
                    palette: palette,
                  )
                : InsightHintText(l10n.chartNeedTwoHealth, palette: palette),
          ),
          InsightCard(
            title: l10n.chartWateringTitle,
            caption: intervals.isNotEmpty
                ? _wateringCaption(l10n, intervals)
                : null,
            chartLabel: intervals.isNotEmpty
                ? l10n.chartWateringSemantics(
                    intervals.length, _wateringCaption(l10n, intervals))
                : null,
            transparent: transparent,
            palette: palette,
            child: intervals.isNotEmpty
                ? WateringChart(
                    intervals: intervals,
                    idealDays: pws?.effectiveFrequencyDays,
                    palette: palette,
                  )
                : InsightHintText(l10n.chartNeedTwoWaterings, palette: palette),
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
          calendarDaysBetween(waterings[i - 1].date, waterings[i].date);
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
        ? l10n.chartWateringSummary(formatChartNumber(avg), ideal)
        : l10n.chartWateringAvgOnly(formatChartNumber(avg));
  }

  /// Key line for the event markers actually visible in the chart's window:
  /// the observação (note) logged with each care event (poda, fertilização,
  /// defensivos, ...) when there is one, otherwise just which types occurred.
  /// [spoken] swaps the emoji markers for the type names, for screen readers.
  String? _eventsCaption(AppLocalizations l10n, List<EntryModel> events,
      List<EntryModel> points,
      {bool spoken = false}) {
    final start = points.first.date;
    final end = points.last.date;
    final visible = events
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
    if (visible.isEmpty) return null;

    final notes =
        visible.where((e) => (e.note ?? '').trim().isNotEmpty).toList();
    if (notes.isEmpty) {
      final present = visible.map((e) => e.type).toSet();
      return spoken
          ? present.map((t) => t.label(l10n)).join(', ')
          : present.map((t) => '${t.emoji} ${t.label(l10n)}').join('   ');
    }
    // Keep the key short: only the most recent notes, with a count of the
    // ones left out.
    const maxNotes = 4;
    final shown = notes.length > maxNotes
        ? notes.sublist(notes.length - maxNotes)
        : notes;
    final dateFmt = DateFormat.Md(l10n.localeName);
    return [
      if (notes.length > maxNotes) '… +${notes.length - maxNotes}',
      for (final e in shown)
        '${spoken ? '${e.type.label(l10n)},' : e.type.emoji} '
            '${dateFmt.format(e.date)} — ${e.note!.trim()}',
    ].join('\n');
  }
}
