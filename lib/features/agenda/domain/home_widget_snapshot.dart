import '../../../core/enums.dart';
import '../../../l10n/app_localizations.dart';
import 'agenda_task.dart';

/// Rows the Android home-screen widget layout has room for.
const homeWidgetMaxRows = 5;

/// One task line of the home-screen widget, with its text already localized.
class HomeWidgetRow {
  const HomeWidgetRow({
    required this.emoji,
    required this.name,
    required this.status,
    required this.plantId,
    required this.canWater,
  });

  final String emoji;
  final String name;

  /// "2 d late" / "today".
  final String status;
  final String plantId;

  /// Irrigation rows get a "Watered" button.
  final bool canWater;

  Map<String, Object> toJson() => {
        'emoji': emoji,
        'name': name,
        'status': status,
        'plantId': plantId,
        'water': canWater,
      };
}

/// What the home-screen widget shows: the agenda's overdue and due-today
/// tasks on [day]. Once that day is over the native widget treats the
/// snapshot as stale and asks for a fresh one.
class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({
    required this.day,
    required this.dueCount,
    required this.header,
    required this.rows,
    required this.more,
  });

  /// Local midnight of the day the snapshot was computed for.
  final DateTime day;
  final int dueCount;

  /// "3 due today" / "All caught up! 🌿".
  final String header;
  final List<HomeWidgetRow> rows;

  /// "+2 more" when not every due task fits; empty otherwise.
  final String more;

  /// yyyy-MM-dd, compared by the native side with the device's current date.
  String get dayKey => '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  Map<String, Object> toJson() => {
        'day': dayKey,
        'count': dueCount,
        'header': header,
        'rows': [for (final row in rows) row.toJson()],
        'more': more,
      };
}

/// Builds the widget content from the agenda [tasks] (as sorted by
/// buildAgendaTasks: most overdue first): only the tasks due by today, at
/// most [maxRows] of them.
HomeWidgetSnapshot buildHomeWidgetSnapshot(
  List<AgendaTask> tasks,
  AppLocalizations l10n, {
  required DateTime now,
  int maxRows = homeWidgetMaxRows,
}) {
  final due = [
    for (final task in tasks)
      if (task.isDue) task
  ];
  final shown = due.take(maxRows);
  return HomeWidgetSnapshot(
    day: DateTime(now.year, now.month, now.day),
    dueCount: due.length,
    header: due.isEmpty
        ? l10n.agendaAllCaughtUp
        : l10n.homeWidgetDueCount(due.length),
    rows: [
      for (final task in shown)
        HomeWidgetRow(
          emoji: task.entryType.emoji,
          name: task.plant.plant.nickname,
          status: task.daysRelative > 0
              ? l10n.homeWidgetOverdue(task.daysRelative)
              : l10n.homeWidgetToday,
          plantId: task.plant.plant.id,
          canWater: task.kind == AgendaTaskKind.irrigation,
        ),
    ],
    more: due.length > maxRows ? l10n.homeWidgetMore(due.length - maxRows) : '',
  );
}
