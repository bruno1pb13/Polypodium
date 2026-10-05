import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/workspaces/domain/garden.dart';
import 'package:polypodium/features/workspaces/presentation/widgets/garden_picker_dialog.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

void main() {
  const gardens = [
    Garden(id: 'u1', name: '', personal: true, role: 'owner'),
    Garden(
        id: 'g1',
        name: 'Horta',
        personal: false,
        role: 'member',
        ownerEmail: 'ela@x.com'),
    Garden(
        id: 'u2',
        name: '',
        personal: true,
        role: 'member',
        ownerEmail: 'ele@x.com'),
  ];

  Garden? picked;
  late AppLocalizations l10n;

  Future<void> pump(WidgetTester tester, {ThemeData? theme}) async {
    picked = null;
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        l10n = AppLocalizations.of(context);
        return Scaffold(
          body: TextButton(
            onPressed: () async => picked = await showDialog<Garden>(
              context: context,
              builder: (_) => const GardenPickerDialog(gardens: gardens),
            ),
            child: const Text('open'),
          ),
        );
      }),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('names each garden and returns the one tapped', (tester) async {
    await pump(tester);

    expect(find.text('Jardim pessoal'), findsOneWidget);
    expect(find.text('Horta'), findsOneWidget);
    expect(find.text('Jardim de ele@x.com'), findsOneWidget);

    await tester.tap(find.text('Horta'));
    await tester.pumpAndSettle();
    expect(picked?.id, 'g1');
  });

  testWidgets('the own personal garden is stored as no garden at all',
      (tester) async {
    await pump(tester);
    expect(gardenChoiceFor(gardens[0], l10n), isNull);
    expect(gardenChoiceFor(gardens[1], l10n), (id: 'g1', name: 'Horta'));
    // Someone else's personal garden is named after its owner.
    expect(gardenChoiceFor(gardens[2], l10n),
        (id: 'u2', name: 'Jardim de ele@x.com'));
  });

  for (final (name, theme) in appThemes) {
    testWidgets('meets the accessibility guidelines ($name)', (tester) async {
      await pump(tester, theme: theme);
      await expectTapTargetGuidelines(tester);
      await expectReadableText(tester);
    });
  }
}
