import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/plants/domain/plant_model.dart';
import '../../features/species/domain/species_model.dart';

class NotificationService {
  NotificationService._();

  static const irrigationCheckTask = 'irrigation-check';
  static const _channelId = 'plantlog_irrigation';
  static const _channelName = 'Irrigação';

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName.identifier));
    } catch (e) {
      // ignore: avoid_print
      print('[NotificationService] Failed to set local location, falling back to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );

    // Request permissions for Android 13+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    // Android 8+ requires an explicit notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.defaultImportance,
          ),
        );
  }

  /// Schedules (or reschedules) the irrigation reminder for a plant.
  static Future<void> scheduleIrrigationNotification({
    required PlantModel plant,
    required SpeciesModel species,
  }) async {
    final frequencyDays = plant.irrigationFrequencyDays ??
        species.defaultIrrigationFrequencyDays;
    final scheduledDate = _nextIrrigationTime(plant.lastIrrigatedAt, frequencyDays);

    await _plugin.zonedSchedule(
      _notificationId(plant.id),
      'Hora de regar! 🌿',
      '${plant.nickname} precisa ser regada hoje.',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Lembretes de irrigação das suas plantas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(String plantId) =>
      _plugin.cancel(_notificationId(plantId));

  /// Called from the WorkManager background isolate to reschedule all plants.
  // TODO(sync): This method will also trigger a background sync pass
  static Future<void> checkAndRescheduleAll() async {
    // WorkManager isolate: instantiate database directly (no Riverpod available)
    // ignore: avoid_print
    print('[NotificationService] Background check triggered');
    // Implementation detail: import AppDatabase and instantiate here when
    // WorkManager isolation issues are resolved at platform setup.
  }

  // ---------------------------------------------------------------------------

  static tz.TZDateTime _nextIrrigationTime(
    DateTime? lastIrrigatedAt,
    int frequencyDays,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    final base = lastIrrigatedAt == null
        ? now
        : tz.TZDateTime.from(lastIrrigatedAt, tz.local)
            .add(Duration(days: frequencyDays));

    // Notify at 9am on the due date
    var scheduled =
        tz.TZDateTime(tz.local, base.year, base.month, base.day, 9);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Derives a stable int ID from a UUID string.
  static int _notificationId(String uuid) => uuid.hashCode.abs() % 0x7FFFFFFF;
}
