import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/entries/presentation/providers/entries_providers.dart';
import '../../features/plants/presentation/providers/plants_providers.dart';
import '../../features/plants/presentation/screens/plant_detail_screen.dart';
import 'notification_service.dart';
import 'reminder_payload.dart';

/// Handles notification responses delivered to the UI isolate: taps on a
/// reminder (open the app, and the plant when it's the only one listed) and
/// any action button the platform hands to the running app instead of
/// [onBackgroundNotificationResponse].
class NotificationResponseHandler {
  NotificationResponseHandler(this._container, this.navigatorKey);

  final ProviderContainer _container;

  /// Attached to the app's MaterialApp so a tap can push a screen without a
  /// [BuildContext].
  final GlobalKey<NavigatorState> navigatorKey;

  Future<void> handle(NotificationResponse response) async {
    final payload = ReminderPayload.decode(response.payload);
    if (payload == null) return;
    try {
      switch (response.actionId) {
        case ReminderAction.water:
          // Skip plants deleted or archived since the notification was
          // scheduled.
          final plants =
              await _container.read(plantsRepositoryProvider).getAll();
          final existing = {
            for (final plant in plants)
              if (plant.isActive) plant.id
          };
          await _container
              .read(entryMutationsProvider)
              .recordIrrigation(payload.plantIds.where(existing.contains));
        case ReminderAction.snooze:
          await NotificationService.snoozeReminder(payload);
          await _container
              .read(plantsRepositoryProvider)
              .rescheduleNotifications();
        default:
          if (response.notificationResponseType ==
              NotificationResponseType.selectedNotification) {
            _openPlant(payload);
          }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[NotificationResponseHandler] Failed to handle response: $e');
    }
  }

  /// Opening the app is all a tap does for a multi-plant reminder; with a
  /// single plant it also lands on that plant's detail screen.
  void _openPlant(ReminderPayload payload, {bool retry = true}) {
    if (payload.plantIds.length != 1) return;
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      // App launched by the tap: the navigator exists after the first frame.
      if (retry) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _openPlant(payload, retry: false));
      }
      return;
    }
    navigator.push(MaterialPageRoute(
      builder: (_) => PlantDetailScreen(plantId: payload.plantIds.single),
    ));
  }
}
