import '../../../core/enums.dart';
import '../../../core/utils/date_utils.dart';
import '../../plants/domain/plant_model.dart';

/// Entry types a recurring reminder can be configured for. Irrigation and
/// pesticide have their own reminder mechanisms; measurement/condition types
/// (height, chlorosis, pest) and free-form ones don't make sense as a
/// recurring chore.
const reminderEntryTypes = [
  EntryType.fertilizer,
  EntryType.pruning,
  EntryType.observation,
  EntryType.repotting,
];

class ReminderModel {
  final String id;
  final String plantId;
  final EntryType entryType;
  final int intervalDays;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;

  const ReminderModel({
    required this.id,
    required this.plantId,
    required this.entryType,
    required this.intervalDays,
    this.enabled = true,
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.localRev = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  ReminderModel copyWith({
    int? intervalDays,
    bool? enabled,
    DateTime? updatedAt,
  }) =>
      ReminderModel(
        id: id,
        plantId: plantId,
        entryType: entryType,
        intervalDays: intervalDays ?? this.intervalDays,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        localRev: localRev,
      );
}

/// A reminder resolved against the plant's diary: [lastDoneAt] is the date
/// of the most recent (non-deleted) entry of the reminder's type.
class ReminderStatus {
  final ReminderModel reminder;
  final DateTime? lastDoneAt;

  const ReminderStatus({required this.reminder, this.lastDoneAt});

  /// Calendar date (midnight) the care is next due. Counted from the last
  /// time it was done; when it was never recorded, from the reminder's
  /// creation — creating a reminder starts the count instead of flagging the
  /// care as overdue right away.
  DateTime get dueDate {
    final anchor = (lastDoneAt ?? reminder.createdAt).toLocal();
    return DateTime(
        anchor.year, anchor.month, anchor.day + reminder.intervalDays);
  }

  /// Positive = days overdue, 0 = due today, negative = days until due.
  int daysRelative([DateTime? now]) => calendarDaysBetween(dueDate, now);

  bool isDue([DateTime? now]) => daysRelative(now) >= 0;
}

/// A reminder together with its plant, as fed to the notification schedule.
class PlantReminder {
  final PlantModel plant;
  final ReminderStatus status;

  const PlantReminder({required this.plant, required this.status});

  EntryType get entryType => status.reminder.entryType;
}
