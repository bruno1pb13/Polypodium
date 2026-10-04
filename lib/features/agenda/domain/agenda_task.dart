import '../../../core/enums.dart';
import '../../plants/domain/plant_model.dart';
import '../../reminders/domain/reminder_model.dart';

enum AgendaTaskKind { irrigation, pesticide, care }

enum AgendaBucket { overdue, today, upcoming }

/// One pending care task of a plant, due on [dueDate].
class AgendaTask {
  final PlantWithSpecies plant;
  final AgendaTaskKind kind;
  final EntryType entryType;

  /// Local midnight of the calendar day the task is due.
  final DateTime dueDate;

  /// Positive = days overdue, 0 = due today, negative = days until due.
  final int daysRelative;

  const AgendaTask({
    required this.plant,
    required this.kind,
    required this.entryType,
    required this.dueDate,
    required this.daysRelative,
  });

  AgendaBucket get bucket => daysRelative > 0
      ? AgendaBucket.overdue
      : daysRelative == 0
          ? AgendaBucket.today
          : AgendaBucket.upcoming;

  /// Overdue or due today.
  bool get isDue => daysRelative >= 0;
}

/// How far ahead the agenda looks, in days after today.
const agendaHorizonDays = 7;

/// Every pending task of the active plants, due up to [agendaHorizonDays]
/// days from today: irrigation, pesticide reapplication and enabled
/// recurring reminders. Sorted most overdue first, then by due date; ties
/// by task kind and plant nickname.
///
/// The due-date math is the one the plant model and [ReminderStatus] already
/// do (calendar days, like the notifications).
List<AgendaTask> buildAgendaTasks({
  required List<PlantWithSpecies> plants,
  required List<ReminderStatus> reminders,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime dayAt(int daysRelative) =>
      DateTime(today.year, today.month, today.day - daysRelative);
  bool inRange(int daysRelative) => daysRelative >= -agendaHorizonDays;

  final active = {
    for (final p in plants)
      if (p.plant.isActive) p.plant.id: p,
  };

  final tasks = <AgendaTask>[];
  for (final p in active.values) {
    final irrigation = p.daysRelativeToSchedule;
    if (irrigation != null && inRange(irrigation)) {
      tasks.add(AgendaTask(
        plant: p,
        kind: AgendaTaskKind.irrigation,
        entryType: EntryType.irrigation,
        dueDate: dayAt(irrigation),
        daysRelative: irrigation,
      ));
    }
    final pesticide = p.pesticideDaysRelative;
    if (pesticide != null && inRange(pesticide)) {
      tasks.add(AgendaTask(
        plant: p,
        kind: AgendaTaskKind.pesticide,
        entryType: EntryType.pesticide,
        dueDate: dayAt(pesticide),
        daysRelative: pesticide,
      ));
    }
  }

  for (final status in reminders) {
    if (!status.reminder.enabled) continue;
    final plant = active[status.reminder.plantId];
    if (plant == null) continue;
    final days = status.daysRelative(now);
    if (!inRange(days)) continue;
    tasks.add(AgendaTask(
      plant: plant,
      kind: AgendaTaskKind.care,
      entryType: status.reminder.entryType,
      dueDate: status.dueDate,
      daysRelative: days,
    ));
  }

  tasks.sort((a, b) {
    final byDays = b.daysRelative.compareTo(a.daysRelative);
    if (byDays != 0) return byDays;
    final byKind = a.kind.index.compareTo(b.kind.index);
    if (byKind != 0) return byKind;
    final byName = a.plant.plant.nickname
        .toLowerCase()
        .compareTo(b.plant.plant.nickname.toLowerCase());
    if (byName != 0) return byName;
    return a.entryType.index.compareTo(b.entryType.index);
  });
  return tasks;
}
