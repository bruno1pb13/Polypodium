import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/updates/update_checker.dart';
import 'package:polypodium/core/updates/update_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeChecker implements UpdateChecker {
  AvailableUpdate? next;
  Object? error;
  int checks = 0;
  final installed = <AvailableUpdate>[];

  @override
  Future<AvailableUpdate?> check() async {
    checks++;
    if (error != null) throw error!;
    return next;
  }

  @override
  Future<void> install(AvailableUpdate update) async => installed.add(update);
}

const _v13 = AvailableUpdate(id: 'v1.3.0', version: '1.3.0');

void main() {
  late _FakeChecker checker;
  late ProviderContainer container;

  UpdateController controller() =>
      container.read(updateControllerProvider.notifier);
  AvailableUpdate? state() => container.read(updateControllerProvider);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    checker = _FakeChecker();
    container = ProviderContainer(overrides: [
      updateCheckerProvider.overrideWith((ref) async => checker),
    ]);
  });

  tearDown(() => container.dispose());

  test('an available update is offered and keeps being checked', () async {
    checker.next = _v13;
    await controller().checkIfDue();
    expect(state(), same(_v13));

    // A fresh launch still offers it: no quiet period while one is pending.
    container.invalidate(updateControllerProvider);
    await controller().checkIfDue();
    expect(checker.checks, 2);
    expect(state(), same(_v13));
  });

  test('once up to date, automatic checks wait a day', () async {
    await controller().checkIfDue();
    checker.next = _v13;
    await controller().checkIfDue();
    expect(checker.checks, 1);
    expect(state(), isNull);

    // The manual check ignores the throttle.
    expect(await controller().checkNow(), UpdateCheckResult.available);
    expect(state(), same(_v13));
  });

  test('the day-old check runs again', () async {
    SharedPreferences.setMockInitialValues({
      'updates.lastCheck': DateTime.now()
          .subtract(const Duration(days: 1, minutes: 1))
          .millisecondsSinceEpoch,
    });
    checker.next = _v13;
    await controller().checkIfDue();
    expect(state(), same(_v13));
  });

  test('a dismissed version stays hidden until a newer one or a manual '
      'check', () async {
    checker.next = _v13;
    await controller().checkIfDue();
    await controller().dismiss();
    expect(state(), isNull);

    await controller().checkIfDue();
    expect(state(), isNull);

    checker.next = const AvailableUpdate(id: 'v1.4.0', version: '1.4.0');
    await controller().checkIfDue();
    expect(state()!.id, 'v1.4.0');

    await controller().dismiss();
    expect(await controller().checkNow(), UpdateCheckResult.available);
    expect(state()!.id, 'v1.4.0');
  });

  test('failures are silent and do not start the quiet period', () async {
    checker.error = Exception('offline');
    expect(await controller().checkNow(), UpdateCheckResult.failed);
    expect(state(), isNull);

    checker.error = null;
    checker.next = _v13;
    await controller().checkIfDue();
    expect(state(), same(_v13));
  });

  test('install hands the offered update to the checker', () async {
    checker.next = _v13;
    await controller().checkIfDue();
    await controller().install();
    expect(checker.installed, [_v13]);
  });

  test('builds without a checker report unsupported', () async {
    final noChecker = ProviderContainer(overrides: [
      updateCheckerProvider.overrideWith((ref) async => null),
    ]);
    addTearDown(noChecker.dispose);
    expect(await noChecker.read(updateControllerProvider.notifier).checkNow(),
        UpdateCheckResult.unsupported);
  });
}
