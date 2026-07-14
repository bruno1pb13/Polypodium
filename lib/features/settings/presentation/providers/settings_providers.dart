import 'package:flutter/material.dart' show TimeOfDay;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../data/settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return SettingsRepository(prefs);
}

@riverpod
class NotificationsEnabledNotifier extends _$NotificationsEnabledNotifier {
  @override
  bool build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.areNotificationsEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    // Permissions are only requested on an explicit opt-in, never at app
    // startup; turning the switch on is that opt-in.
    if (enabled) {
      await NotificationService.requestPermissions();
    }
    await ref.read(settingsRepositoryProvider).setNotificationsEnabled(enabled);
    state = enabled;

    // Reschedule all notifications based on the new setting
    await ref.read(settingsRepositoryProvider).rescheduleAllNotifications(ref);
  }
}

@riverpod
class NotificationTimeNotifier extends _$NotificationTimeNotifier {
  @override
  TimeOfDay build() {
    final time = ref.watch(settingsRepositoryProvider).getNotificationTime();
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  Future<void> setTime(TimeOfDay time) async {
    await ref
        .read(settingsRepositoryProvider)
        .setNotificationTime(time.hour, time.minute);
    state = time;

    await ref.read(settingsRepositoryProvider).rescheduleAllNotifications(ref);
  }
}

@riverpod
class TransparencyEnabledNotifier extends _$TransparencyEnabledNotifier {
  @override
  bool build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.isTransparencyEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setTransparencyEnabled(enabled);
    state = enabled;
  }
}

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  String build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getThemeMode();
  }

  Future<void> setThemeMode(String themeMode) async {
    await ref.read(settingsRepositoryProvider).setThemeMode(themeMode);
    state = themeMode;
  }
}

@riverpod
class AutoSyncEnabledNotifier extends _$AutoSyncEnabledNotifier {
  @override
  bool build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.isAutoSyncEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setAutoSyncEnabled(enabled);
    state = enabled;
  }
}

