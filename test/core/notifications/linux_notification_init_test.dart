import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:polypodium/core/notifications/linux_notification_init.dart';

class _MockBus extends Mock implements DBusClient {}

void main() {
  late _MockBus bus;

  setUp(() {
    bus = _MockBus();
    when(() => bus.close()).thenAnswer((_) async {});
  });

  test('missing session socket skips plugin without uncaught async errors',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('notification-bus-');
    addTearDown(() => directory.delete(recursive: true));
    final client =
        DBusClient(DBusAddress('unix:path=${directory.path}/missing-bus'));
    final diagnostics = <String>[];
    var initialized = false;
    await runZoned(
      () => initializeLinuxNotifications(() async {
        initialized = true;
      }, client: client),
      zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {
        diagnostics.add(line);
      }),
    );
    // Flush detached work too: flutter_test fails on any uncaught zone error.
    await Future<void>.delayed(Duration.zero);
    expect(initialized, isFalse);
    expect(diagnostics.single, contains('Linux notifications unavailable'));
    expect(diagnostics.single, contains('SocketException'));
  }, skip: Platform.isWindows);

  test('working session closes probe before initializing exactly once',
      () async {
    when(() => bus.listNames()).thenAnswer((_) async => []);
    var initialized = 0;
    await initializeLinuxNotifications(() async {
      verify(() => bus.close()).called(1);
      initialized++;
    }, client: bus);
    expect(initialized, 1);
    verify(() => bus.listNames()).called(1);
  });

  test('unexpected probe errors propagate and close the client', () async {
    final error = StateError('unexpected probe failure');
    when(() => bus.listNames()).thenThrow(error);
    await expectLater(
      initializeLinuxNotifications(() async => fail('must not initialize'),
          client: bus),
      throwsA(same(error)),
    );
    verify(() => bus.close()).called(1);
  });

  test('plugin failures are not silenced by the session guard', () async {
    when(() => bus.listNames()).thenAnswer((_) async => []);
    final error = StateError('unexpected plugin failure');
    await expectLater(
      initializeLinuxNotifications(() async => throw error, client: bus),
      throwsA(same(error)),
    );
    verify(() => bus.close()).called(1);
  });
}
