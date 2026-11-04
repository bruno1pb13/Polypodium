import 'dart:io';

import 'package:dbus/dbus.dart';

/// The Linux plugin starts D-Bus signal subscriptions whose connection errors
/// escape its initialize() future. Check the session before creating them.
/// A missing session is normal in headless environments; other errors propagate.
Future<void> initializeLinuxNotifications(
  Future<void> Function() initialize, {
  DBusClient? client,
}) async {
  final session = client ?? DBusClient.session();
  try {
    // A real D-Bus round trip, not an environment-variable or socket-file check.
    // This neither starts a notification server nor subscribes to signals.
    await session.listNames();
  } on SocketException catch (error) {
    // ignore: avoid_print
    print('[NotificationService] Linux notifications unavailable: '
        'cannot connect to the session D-Bus; continuing without notifications. '
        '$error');
    return;
  } finally {
    await session.close();
  }
  await initialize();
}
