import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/sync/sync_providers.dart';
import 'package:polypodium/features/data_transfer/domain/data_transfer_permission.dart';
import 'package:polypodium/features/data_transfer/presentation/providers/data_transfer_providers.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/settings/data/settings_repository.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/settings/presentation/screens/settings_screen.dart';
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
      {Size size = const Size(800, 2000)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    plants = _FakePlantsRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        plantsRepositoryProvider.overrideWithValue(plants),
        activeWorkspaceProvider.overrideWithValue(workspace),
        pendingSyncCountProvider.overrideWith((ref) async => 0),
        dataTransferPermissionProvider
            .overrideWith((ref) async => DataTransferPermission.allowed),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ));
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
    expect(find.text('Servidor de casa'), findsOneWidget);
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
    expect(find.text('Workspace local — não sincroniza'), findsOneWidget);
    expect(find.text('Sincronização automática'), findsNothing);
    expect(find.text('Sincronizar agora'), findsNothing);
  });

  testWidgets('appearance settings persist', (tester) async {
    await pump(tester, Workspace.newLocal());

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

  group('accessibility', () {
    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, remote);
      await expectTapTargetGuidelines(tester);
      await expectReadableText(tester);

      await pump(tester, Workspace.newLocal());
      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });

    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        setTextScale(tester, scale);
        await pump(tester, remote, size: const Size(400, 4000));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
