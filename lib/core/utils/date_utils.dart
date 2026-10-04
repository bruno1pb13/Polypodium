/// Number of calendar days from [from] to [to] (default: now), in local time.
///
/// Unlike `to.difference(from).inDays`, which counts whole 24 h blocks, this
/// compares calendar dates: watering at 23:00 yesterday counts as 1 day ago
/// at 08:00 today. Matches how reminders are scheduled (by due date, see
/// NotificationService.computeNextIrrigationDate). Computed on UTC midnights
/// so DST transitions don't shave an hour off the difference.
int calendarDaysBetween(DateTime from, [DateTime? to]) {
  final a = from.toLocal();
  final b = (to ?? DateTime.now()).toLocal();
  return DateTime.utc(b.year, b.month, b.day)
      .difference(DateTime.utc(a.year, a.month, a.day))
      .inDays;
}
