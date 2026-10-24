import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/database/database_provider.dart';
import 'package:polypodium/core/sync/sync_providers.dart';
import 'package:polypodium/features/data_transfer/domain/data_transfer_permission.dart';
import 'package:polypodium/features/data_transfer/presentation/providers/data_transfer_providers.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/settings/data/settings_repository.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/settings/presentation/screens/settings_screen.dart';
import 'package:polypodium/features/weather/presentation/providers/weather_providers.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/accessibility.dart';

class _FakePlantsRepository implements PlantsRepository {
  int reschedules = 0;

  @override
  Future<void> rescheduleNotifications() async => reschedules++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoLocations extends LocationsNotifier {
  @override
  Stream<List<LocationModel>> build() => Stream.value(const []);
}

void main() {
  final remote = Workspace(
    id: 'w1',
    name: 'Servidor de casa',
    type: WorkspaceType.remote,
    serverUrl: 'https://polypodium.example',
    userEmail: 'ana@example.com',
    token: 'token',
    createdAt: DateTime(2026, 1, 1),
  );

  late SharedPreferences prefs;
  late _FakePlantsRepository plants;

  Future<void> pump(WidgetTester tester, Workspace workspace,
      {Size size = const Size(800, 2000),
      ThemeData? theme,
      Map<String, Object> initialPrefs = const {}}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(initialPrefs);
    prefs = await SharedPreferences.getInstance();
    plants = _FakePlantsRepository();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        serverWeatherEnabledProvider.overrideWith((ref) async => true),
        locationsNotifierProvider.overrideWith(_NoLocations.new),
        localWeatherRegionsProvider.overrideWith((ref) => Stream.value([])),
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        plantsRepositoryProvider.overrideWithValue(plants),
        activeWorkspaceProvider.overrideWithValue(workspace),
        pendingSyncCountProvider.overrideWith((ref) async => 0),
        dataTransferPermissionProvider
            .overrideWith((ref) async => DataTransferPermission.allowed),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// Opens [category] in the column of the two-column layout.
  Future<void> open(WidgetTester tester, SettingsCategory category) async {
    await tester.tap(find.byKey(ValueKey('settings-category-${category.name}')));
    await tester.pumpAndSettle();
  }

  SwitchListTile switchTile(WidgetTester tester, String title) =>
      tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title));

  testWidgets('toggling notifications persists it and reschedules',
      (tester) async {
    await pump(tester, Workspace.newLocal());
    expect(switchTile(tester, 'Notificações de Rega').value, isTrue);

    await tester.tap(find.text('Notificações de Rega'));
    await tester.pumpAndSettle();
    expect(switchTile(tester, 'Notificações de Rega').value, isFalse);
    expect(prefs.getBool('notifications_enabled'), isFalse);
    expect(plants.reschedules, 1);
    // The reminder time only applies while notifications are on.
    expect(
      tester
          .widget<ListTile>(
              find.widgetWithText(ListTile, 'Horário dos lembretes'))
          .enabled,
      isFalse,
    );

    await tester.tap(find.text('Notificações de Rega'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('notifications_enabled'), isTrue);
    expect(plants.reschedules, 2);
  });

  testWidgets('toggling auto-sync persists it', (tester) async {
    await pump(tester, remote);
    await open(tester, SettingsCategory.sync);
    // In the column's summary and atop the sync settings.
    expect(find.text('Servidor de casa'), findsNWidgets(2));
    expect(find.text('Tudo sincronizado'), findsOneWidget);
    expect(switchTile(tester, 'Sincronização automática').value, isTrue);

    await tester.tap(find.text('Sincronização automática'));
    await tester.pumpAndSettle();
    expect(switchTile(tester, 'Sincronização automática').value, isFalse);
    expect(prefs.getBool('auto_sync_enabled'), isFalse);

    await tester.tap(find.text('Sincronização automática'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('auto_sync_enabled'), isTrue);
  });

  testWidgets('a local workspace has no sync controls', (tester) async {
    await pump(tester, Workspace.newLocal());
    await open(tester, SettingsCategory.sync);
    expect(find.text('Workspace local — não sincroniza'), findsOneWidget);
    expect(find.text('Sincronização automática'), findsNothing);
    expect(find.text('Sincronizar agora'), findsNothing);
  });

  testWidgets('the local weather asks before sending anything out',
      (tester) async {
    await pump(tester, Workspace.newLocal());
    await open(tester, SettingsCategory.weather);
    expect(switchTile(tester, 'Analisar a previsão do tempo').value, isFalse);
    // The notice is there before it is turned on.
    expect(find.text('Envia dados a um serviço de terceiros'), findsOneWidget);
    expect(find.textContaining('endereço IP'), findsOneWidget);
    expect(find.text('Parâmetros da análise'), findsNothing);

    await tester.tap(find.text('Analisar a previsão do tempo'));
    await tester.pumpAndSettle();
    expect(find.text('Ligar a análise do clima?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(switchTile(tester, 'Analisar a previsão do tempo').value, isFalse);
    expect(prefs.getBool('local_weather_enabled'), isNull);

    await tester.tap(find.text('Analisar a previsão do tempo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ligar e enviar'));
    await tester.pumpAndSettle();
    expect(switchTile(tester, 'Analisar a previsão do tempo').value, isTrue);
    expect(prefs.getBool('local_weather_enabled'), isTrue);
    expect(find.text('Ligada, pelo Open-Meteo'), findsOneWidget);
    expect(find.textContaining('Nenhum local tem coordenadas'), findsOneWidget);
    expect(find.text('Parâmetros da análise'), findsOneWidget);

    // A tap in the middle of the rain slider (0–50 mm) sets 25 mm.
    await tester.tap(find.byType(Slider).first);
    await tester.pumpAndSettle();
    expect(prefs.getString('local_watering_rules'), '{"minRainMm":25.0}');
    expect(find.text('25,0 mm'), findsOneWidget);

    await tester.tap(find.text('Restaurar padrões'));
    await tester.pumpAndSettle();
    expect(prefs.getString('local_watering_rules'), isNull);

    await tester.tap(find.text('Analisar a previsão do tempo'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('local_weather_enabled'), isFalse);
    expect(find.text('Parâmetros da análise'), findsNothing);
  });

  testWidgets('a workspace with a server leaves the weather to it',
      (tester) async {
    await pump(tester, remote);
    expect(find.text('Pelo servidor do workspace'), findsOneWidget);
    await open(tester, SettingsCategory.weather);
    expect(find.text('Calculada pelo servidor'), findsOneWidget);
    expect(find.text('O servidor está com a previsão do tempo ligada.'),
        findsOneWidget);
    expect(find.text('Analisar a previsão do tempo'), findsNothing);
  });

  testWidgets('appearance settings persist', (tester) async {
    await pump(tester, Workspace.newLocal());
    await open(tester, SettingsCategory.appearance);

    await tester.tap(find.text('Transparência e Blur'));
    await tester.pumpAndSettle();
    expect(switchTile(tester, 'Transparência e Blur').value, isFalse);
    expect(prefs.getBool('transparency_enabled'), isFalse);

    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();
    expect(prefs.getString('theme_mode'), 'dark');
    expect(
      tester
          .widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>))
          .selected,
      {'dark'},
    );
  });

  testWidgets('the column summarizes each category', (tester) async {
    await pump(tester, remote);
    expect(find.text('Ativados, às 09:00'), findsOneWidget);
    expect(find.text('Tema: Auto'), findsOneWidget);
    // The workspace's name, in the column only until sync is opened.
    expect(find.text('Servidor de casa'), findsOneWidget);
  });

  testWidgets('narrow screens open each category on its own page',
      (tester) async {
    await pump(tester, remote, size: const Size(400, 900));
    expect(find.text('Notificações de Rega'), findsNothing);

    await tester.tap(find.text('Aparência'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsCategoryPage), findsOneWidget);
    expect(find.text('Transparência e Blur'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsCategoryPage), findsNothing);

    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();
    expect(find.text('Política de privacidade'), findsOneWidget);
  });

  group('accessibility', () {
    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, remote);
      await expectTapTargetGuidelines(tester);
      await expectReadableText(tester);

      await pump(tester, Workspace.newLocal());
      await expectTapTargetGuidelines(tester);

      await pump(tester, Workspace.newLocal(),
          initialPrefs: {'local_weather_enabled': true});
      await open(tester, SettingsCategory.weather);
      await expectTapTargetGuidelines(tester);
      await expectReadableText(tester);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('text is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, remote, theme: theme);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        setTextScale(tester, scale);
        await pump(tester, remote, size: const Size(400, 4000));
        expect(tester.takeException(), isNull);
        for (final category in SettingsCategory.values) {
          await tester.tap(find.byKey(
              ValueKey('settings-category-${category.name}')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Voltar'));
          await tester.pumpAndSettle();
        }
      });
    }
  });
}
