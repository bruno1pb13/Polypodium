import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/workspaces/presentation/widgets/workspace_login_dialog.dart';
import 'package:polypodium/l10n/app_localizations.dart';

void main() {
  late List<String> calls;
  bool? closedWith;

  Future<void> openDialog(
    WidgetTester tester, {
    required Future<bool> Function() supportsWeather,
    Future<void> Function()? onEnableWeather,
    bool hasLocalData = false,
  }) async {
    calls = [];
    closedWith = null;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            closedWith = await showDialog<bool>(
              context: context,
              builder: (_) => WorkspaceLoginDialog(
                title: 'Entrar',
                checkServer: (_) async {},
                checkHasUsers: (_) async => false,
                onSubmit: (_, __, ___) async => calls.add('login'),
                onRegister: (_, __, ___, ____) async => calls.add('register'),
                supportsWeather: supportsWeather,
                onEnableWeather: onEnableWeather ??
                    () async => calls.add('enableWeather'),
                hasLocalDataToMigrate: () async => hasLocalData,
                onMigrate: () async => calls.add('migrate'),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'https://srv.test');
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jardim');
    await tester.enterText(fields.at(1), 'admin@test.local');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret1');
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
  }

  testWidgets('asks the first admin to turn weather on', (tester) async {
    await openDialog(tester, supportsWeather: () async => true);

    expect(find.text('Previsão do tempo'), findsOneWidget);
    await tester.tap(find.text('Ligar'));
    await tester.pumpAndSettle();

    expect(calls, ['register', 'enableWeather']);
    expect(closedWith, isTrue);
  });

  testWidgets('declining weather moves on to migrating local data',
      (tester) async {
    await openDialog(tester,
        supportsWeather: () async => true, hasLocalData: true);

    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();
    expect(calls, ['register']);
    expect(find.text('Previsão do tempo'), findsNothing);
    expect(closedWith, isNull, reason: 'migration step still open');
  });

  testWidgets('a failure turning weather on is shown and can be skipped',
      (tester) async {
    await openDialog(tester,
        supportsWeather: () async => true,
        onEnableWeather: () async => throw Exception('offline'));

    await tester.tap(find.text('Ligar'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();
    expect(closedWith, isTrue);
  });

  testWidgets('skips the question on servers without weather',
      (tester) async {
    await openDialog(tester, supportsWeather: () async => false);
    expect(find.text('Previsão do tempo'), findsNothing);
    expect(closedWith, isTrue);
  });
}
