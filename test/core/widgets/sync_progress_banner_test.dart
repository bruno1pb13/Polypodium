import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/sync/sync_providers.dart';
import 'package:polypodium/core/sync/sync_service.dart';
import 'package:polypodium/core/widgets/sync_progress_banner.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _Fixed extends SyncProgressNotifier {
  _Fixed(this.initial);

  final SyncProgress? initial;

  @override
  SyncProgress? build() => initial;
}

Future<void> _pump(WidgetTester tester, SyncProgress? progress) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      syncProgressNotifierProvider.overrideWith(() => _Fixed(progress)),
    ],
    child: const MaterialApp(
      locale: Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          children: [
            SyncProgressBanner(),
            Expanded(child: Stack(children: [SyncEssentialsOverlay()])),
          ],
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

const _strip = 'Sincronizando em segundo plano — os dados podem estar incompletos';
const _overlay = 'Baixando seu jardim';

void main() {
  testWidgets('a large pull behind the app shows the strip with its count',
      (tester) async {
    await _pump(
        tester,
        const SyncProgress(
            stage: SyncStage.rest, done: 120, total: 900, large: true));

    expect(find.text(_strip), findsOneWidget);
    expect(find.text('120 de 900'), findsOneWidget);
    expect(find.text(_overlay), findsNothing);
  });

  testWidgets('a small pull stays silent', (tester) async {
    await _pump(tester,
        const SyncProgress(stage: SyncStage.rest, done: 20, total: 40));

    expect(find.text(_strip), findsNothing);
    expect(find.text(_overlay), findsNothing);
  });

  testWidgets('the essentials cover the app, without the strip',
      (tester) async {
    await _pump(
        tester,
        const SyncProgress(
            stage: SyncStage.essentials, done: 3, total: 10, large: true));

    expect(find.text(_overlay), findsOneWidget);
    expect(find.text('3 de 10'), findsOneWidget);
    expect(find.text(_strip), findsNothing);
  });

  testWidgets('nothing shows without a pull', (tester) async {
    await _pump(tester, null);

    expect(find.text(_strip), findsNothing);
    expect(find.text(_overlay), findsNothing);
  });

  testWidgets('the host leaves the app all the room, overlay or not',
      (tester) async {
    for (final progress in [
      null,
      const SyncProgress(stage: SyncStage.essentials, done: 0, large: true),
    ]) {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          syncProgressNotifierProvider.overrideWith(() => _Fixed(progress)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SyncEssentialsHost(child: SizedBox(key: Key('app'))),
        ),
      ));
      await tester.pump();

      expect(tester.getSize(find.byKey(const Key('app'))),
          tester.view.physicalSize / tester.view.devicePixelRatio,
          reason: 'progress: $progress');
    }
  });
}
