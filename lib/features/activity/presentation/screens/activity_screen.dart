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
/// days and every entry, grouped by day.
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
                if (activity.days.isEmpty) return const _EmptyState();
                return LayoutBuilder(
                  builder: (context, constraints) => ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: ((constraints.maxWidth - _maxContentWidth) /
                                  2)
                              .clamp(0, double.infinity) +
                          16,
                    ).copyWith(top: 8, bottom: 32),
                    itemCount: activity.days.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => i == 0
                        ? ActivityChartCard(activity: activity)
                        : _DayCard(day: activity.days[i - 1]),
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
                    ExcludeSemantics(
                      child: Text(item.entry.type.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline, size: 64, color: context.glass.tint(0.4)),
            const SizedBox(height: 16),
            Text(
              context.l10n.activityEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.glass.fg, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
