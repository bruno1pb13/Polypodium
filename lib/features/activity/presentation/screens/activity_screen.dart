import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../dashboard/presentation/widgets/dashboard_card.dart';
import '../../../plants/presentation/screens/plant_detail_screen.dart';
import '../../domain/garden_activity.dart';
import '../providers/activity_providers.dart';
import '../widgets/activity_chart_card.dart';

/// Content wider than this is centered instead of stretched.
const _maxContentWidth = 720.0;

/// What was logged in the garden: entries per day of the last [chartDays]
/// days and the entries of the selected [ActivityRange], grouped by day.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(gardenActivityProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.glass.fg),
        title: Text(
          context.l10n.navActivity,
          style: TextStyle(
            color: context.glass.fg,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: context.glass.shadow(Colors.black45),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.glass.scrim(0.5),
                    Colors.transparent,
                    context.glass.scrim(0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: activityAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: context.glass.fg),
              ),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.errorGeneric('$e'),
                  style: TextStyle(color: context.glass.fg),
                ),
              ),
              data: (activity) {
                final items = <Widget>[
                  const _RangeSelector(),
                  ActivityChartCard(activity: activity),
                  if (activity.days.isEmpty)
                    const _EmptyRange()
                  else
                    for (final day in activity.days) _DayCard(day: day),
                ];
                return LayoutBuilder(
                  builder: (context, constraints) => ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ((constraints.maxWidth - _maxContentWidth) / 2)
                                  .clamp(0, double.infinity) +
                              16,
                    ).copyWith(top: 8, bottom: 32),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => items[i],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  final ActivityDay day;

  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = dashboardPalette(context, ref);
    final time = DateFormat.Hm(l10n.localeName);
    final title = switch (calendarDaysBetween(day.day)) {
      0 => l10n.agendaToday,
      1 => l10n.activityYesterday,
      _ => toBeginningOfSentenceCase(
          DateFormat.MMMMEEEEd(l10n.localeName).format(day.day)),
    };

    return DashboardCard(
      title: title,
      child: Column(
        children: [
          for (final (i, item) in day.entries.indexed) ...[
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
                    _EntryTypeIcon(type: item.entry.type),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: item.plant.plant.nickname,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: ' · ${item.entry.type.label(l10n)}',
                                style: TextStyle(color: palette.inkSoft),
                              ),
                            ]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 13.5, color: palette.ink),
                          ),
                          if (item.entry.note?.trim().isNotEmpty ?? false)
                            Text(
                              item.entry.note!.trim(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.5, color: palette.inkSoft),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time.format(item.entry.date.toLocal()),
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

/// Picks how far back the screen loads entries.
class _RangeSelector extends ConsumerWidget {
  const _RangeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(activityRangeNotifierProvider);

    return SegmentedButton<ActivityRange>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        foregroundColor: context.glass.fg,
        selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: context.glass.scrim(0.3),
        side: BorderSide(color: context.glass.outline),
      ),
      segments: [
        ButtonSegment(
          value: ActivityRange.month,
          label: Text(l10n.activityRangeMonth),
        ),
        ButtonSegment(
          value: ActivityRange.quarter,
          label: Text(l10n.activityRangeQuarter),
        ),
        ButtonSegment(
          value: ActivityRange.year,
          label: Text(l10n.activityRangeYear),
        ),
      ],
      selected: {range},
      onSelectionChanged: (s) =>
          ref.read(activityRangeNotifierProvider.notifier).set(s.single),
    );
  }
}

/// Icon of an entry type in a tinted square; waterings in the water hue.
class _EntryTypeIcon extends ConsumerWidget {
  final EntryType type;

  const _EntryTypeIcon({required this.type});

  static IconData _icon(EntryType type) => switch (type) {
        EntryType.irrigation => Icons.water_drop_outlined,
        EntryType.fertilizer => Icons.eco_outlined,
        EntryType.pruning => Icons.content_cut,
        EntryType.observation => Icons.visibility_outlined,
        EntryType.height => Icons.straighten,
        EntryType.chlorosis => Icons.invert_colors_outlined,
        EntryType.pest => Icons.bug_report_outlined,
        EntryType.pesticide => Icons.science_outlined,
        EntryType.other => Icons.notes,
        EntryType.history => Icons.history,
        EntryType.repotting => Icons.yard_outlined,
        EntryType.harvest => Icons.shopping_basket_outlined,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = dashboardPalette(context, ref);
    final color = type == EntryType.irrigation ? palette.water : palette.growth;

    // The row's text already names the type.
    return ExcludeSemantics(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_icon(type), size: 18, color: color),
      ),
    );
  }
}

class _EmptyRange extends ConsumerWidget {
  const _EmptyRange();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = dashboardPalette(context, ref);
    return DashboardCard(
      child: Row(
        children: [
          Icon(Icons.timeline, color: palette.inkSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.activityRangeEmpty,
              style: TextStyle(fontSize: 14, color: palette.ink),
            ),
          ),
        ],
      ),
    );
  }
}
