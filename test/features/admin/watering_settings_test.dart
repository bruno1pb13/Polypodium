import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:polypodium/core/sync/sync_providers.dart';
import 'package:polypodium/core/sync/sync_service.dart';
import 'package:polypodium/features/admin/data/admin_client.dart';
import 'package:polypodium/features/admin/domain/server_data_settings.dart';
import 'package:polypodium/features/admin/domain/server_status.dart';
import 'package:polypodium/features/admin/domain/server_watering_settings.dart';
import 'package:polypodium/features/admin/domain/server_weather_status.dart';
import 'package:polypodium/features/admin/presentation/providers/admin_providers.dart';
import 'package:polypodium/features/admin/presentation/screens/server_admin_screen.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _MockAdminClient extends Mock implements AdminClient {}

class _MockSyncService extends Mock implements SyncService {}

Workspace _remote({String url = 'https://plants.example'}) => Workspace(
      id: 'ws-1',
      name: 'Casa',
      type: WorkspaceType.remote,
      serverUrl: url,
      token: 't',
      role: 'admin',
      createdAt: DateTime(2026),
    );

const _defaults = {
  'minRainMm': 2,
  'rainEfficiency': 0.7,
  'maxPostponeDays': 7,
  'maxAdvanceDays': 2,
  'minDemand': 0.5,
  'maxDemand': 2,
};

ServerWateringSettings _settings(
        {bool enabled = true, Map<String, num> changed = const {}}) =>
    ServerWateringSettings.fromJson({
      'enabled': enabled,
      ..._defaults,
      ...changed,
      'defaults': _defaults,
      'limits': {
        'minRainMm': {'min': 0, 'max': 50},
        'rainEfficiency': {'min': 0, 'max': 1},
        'maxPostponeDays': {'min': 0, 'max': 30},
        'maxAdvanceDays': {'min': 0, 'max': 30},
        'minDemand': {'min': 0.1, 'max': 1},
        'maxDemand': {'min': 1, 'max': 5},
      },
    });

void main() {
  late _MockAdminClient client;
  late _MockSyncService sync;

  setUpAll(() => registerFallbackValue(<WateringRule, double?>{}));

  setUp(() {
    client = _MockAdminClient();
    sync = _MockSyncService();
    when(() => sync.refreshWateringAdvice()).thenAnswer((_) async {});
    when(() => client.wateringSettings(
          serverUrl: any(named: 'serverUrl'),
          token: any(named: 'token'),
        )).thenAnswer((_) async => _settings());
    when(() => client.updateWateringSettings(
          serverUrl: any(named: 'serverUrl'),
          token: any(named: 'token'),
          enabled: any(named: 'enabled'),
          rules: any(named: 'rules'),
        )).thenAnswer((_) async => _settings(changed: {'maxAdvanceDays': 0}));
  });

  ProviderContainer containerFor({required Workspace active}) {
    final container = ProviderContainer(overrides: [
      adminClientProvider.overrideWithValue(client),
      activeWorkspaceProvider.overrideWithValue(active),
      syncServiceProvider.overrideWithValue(sync),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  group('ServerWateringSettings', () {
    test('reads values, defaults and limits', () {
      final s = _settings(changed: {'maxPostponeDays': 3});
      expect(s.enabled, isTrue);
      expect(s.value(WateringRule.maxPostponeDays), 3);
      expect(s.defaults[WateringRule.maxPostponeDays], 7);
      expect(s.limits[WateringRule.minDemand], (min: 0.1, max: 1.0));
      expect(s.isDefault, isFalse);
      expect(_settings().isDefault, isTrue);
    });

    test('tolerates fields it does not know or misses', () {
      final s = ServerWateringSettings.fromJson(
          {'enabled': false, 'minRainMm': 4, 'newRule': 1});
      expect(s.enabled, isFalse);
      expect(s.value(WateringRule.minRainMm), 4);
      expect(s.limits, isEmpty);
    });
  });

  test('changing a rule saves it and refreshes the active server advice',
      () async {
    final workspace = _remote();
    final container = containerFor(active: workspace);
    final provider = serverWateringSettingsNotifierProvider(workspace);
    await container.read(provider.future);

    await container
        .read(provider.notifier)
        .setRule(WateringRule.maxAdvanceDays, 0);

    verify(() => client.updateWateringSettings(
          serverUrl: 'https://plants.example',
          token: 't',
          enabled: null,
          rules: {WateringRule.maxAdvanceDays: 0},
        )).called(1);
    expect(container.read(provider).value!.value(WateringRule.maxAdvanceDays),
        0);
    verify(() => sync.refreshWateringAdvice()).called(1);
  });

  test('another server\'s rules leave this device\'s advice alone', () async {
    final workspace = _remote(url: 'https://other.example');
    final container = containerFor(active: _remote());
    final provider = serverWateringSettingsNotifierProvider(workspace);
    await container.read(provider.future);

    await container.read(provider.notifier).resetRules();

    final rules = verify(() => client.updateWateringSettings(
          serverUrl: 'https://other.example',
          token: 't',
          enabled: null,
          rules: captureAny(named: 'rules'),
        )).captured.single as Map<WateringRule, double?>;
    expect(rules.keys, WateringRule.values);
    expect(rules.values, everyElement(isNull));
    verifyNever(() => sync.refreshWateringAdvice());
  });

  group('admin screen card', () {
    Future<void> pump(WidgetTester tester, {required bool weatherOn}) async {
      final workspace = _remote();
      when(() => client.status(
                serverUrl: any(named: 'serverUrl'),
                token: any(named: 'token'),
              ))
          .thenAnswer((_) async => const ServerStatus(
              uptimeSeconds: 1, version: '3.0.0', userCount: 1));
      when(() => client.getDataSettings(
            serverUrl: any(named: 'serverUrl'),
            token: any(named: 'token'),
          )).thenAnswer((_) async => ServerDataSettings(
            allowMemberExport: true,
            allowMemberImport: true,
            weatherEnabled: weatherOn,
          ));
      when(() => client.weatherStatus(
                serverUrl: any(named: 'serverUrl'),
                token: any(named: 'token'),
              ))
          .thenAnswer((_) async => const ServerWeatherStatus(
              enabled: true, regionCount: 1, failingRegionCount: 0));
      when(() => client.listUsers(
            serverUrl: any(named: 'serverUrl'),
            token: any(named: 'token'),
          )).thenAnswer((_) async => []);

      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          adminClientProvider.overrideWithValue(client),
          activeWorkspaceProvider.overrideWithValue(workspace),
          syncServiceProvider.overrideWithValue(sync),
        ],
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ServerAdminScreen(workspace: workspace),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the rules while weather is on', (tester) async {
      await pump(tester, weatherOn: true);

      expect(find.text('Rega pelo clima'), findsOneWidget);
      expect(find.text('Adiar no máximo'), findsOneWidget);
      expect(find.text('7 dias'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(WateringRule.values.length));
      // Everything at its default: nothing to restore.
      final reset = tester.widget<TextButton>(find.ancestor(
          of: find.text('Restaurar padrões'),
          matching: find.byWidgetPredicate((w) => w is TextButton)));
      expect(reset.onPressed, isNull);
    });

    testWidgets('is hidden while weather is off', (tester) async {
      await pump(tester, weatherOn: false);
      expect(find.text('Rega pelo clima'), findsNothing);
    });
  });
}
