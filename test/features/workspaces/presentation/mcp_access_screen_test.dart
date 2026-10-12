import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/workspaces/data/garden_client.dart';
import 'package:polypodium/features/workspaces/data/mcp_token_client.dart';
import 'package:polypodium/features/workspaces/domain/garden.dart';
import 'package:polypodium/features/workspaces/domain/mcp_token.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/screens/mcp_access_screen.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeGardenClient implements GardenClient {
  @override
  Future<List<Garden>> listGardens(
          {required String serverUrl, required String token}) async =>
      const [
        Garden(id: 'u1', name: '', personal: true, role: 'owner'),
        Garden(id: 'g1', name: 'Horta', personal: false, role: 'owner'),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMcpClient implements McpTokenClient {
  _FakeMcpClient(this.tokens, {this.enabled = true});

  final List<McpToken> tokens;
  final bool enabled;
  final listedGardens = <String>[];
  final created = <({String name, bool canWrite})>[];
  final revoked = <String>[];

  @override
  Future<McpTokenList> listTokens(
      {required String serverUrl,
      required String token,
      required String gardenId}) async {
    listedGardens.add(gardenId);
    return (enabled: enabled, tokens: List.of(tokens));
  }

  @override
  Future<CreatedMcpToken> createToken(
      {required String serverUrl,
      required String token,
      required String gardenId,
      required String name,
      required bool canWrite}) async {
    created.add((name: name, canWrite: canWrite));
    final t = McpToken(
        id: 'new',
        name: name,
        tokenPrefix: 'pmcp_newnew',
        canWrite: canWrite,
        createdAt: DateTime.utc(2026, 10, 12));
    tokens.add(t);
    return (token: t, secret: 'pmcp_newnew_secret');
  }

  @override
  Future<void> revokeToken(
      {required String serverUrl,
      required String token,
      required String gardenId,
      required String tokenId}) async {
    revoked.add(tokenId);
    tokens.removeWhere((t) => t.id == tokenId);
  }
}

void main() {
  final workspace = Workspace(
    id: 'w1',
    name: 'Horta',
    type: WorkspaceType.remote,
    serverUrl: 'https://plantas.example',
    userEmail: 'dona@x.com',
    token: 't',
    deviceId: 'd',
    createdAt: DateTime(2026, 1, 1),
    gardenId: 'g1',
    gardenName: 'Horta',
  );

  _FakeMcpClient client({bool enabled = true}) =>
      _FakeMcpClient(enabled: enabled, [
        McpToken(
          id: 'mine',
          name: 'Claude Desktop',
          tokenPrefix: 'pmcp_aaaaaa',
          canWrite: true,
          createdAt: DateTime.utc(2026, 10, 1),
          lastUsedAt: DateTime.utc(2026, 10, 11, 12),
          email: 'dona@x.com',
        ),
        McpToken(
          id: 'theirs',
          name: 'Cursor',
          tokenPrefix: 'pmcp_bbbbbb',
          canWrite: false,
          createdAt: DateTime.utc(2026, 10, 2),
          email: 'membro@x.com',
        ),
      ]);

  Future<void> pump(WidgetTester tester, _FakeMcpClient mcp,
      {ThemeData? theme}) async {
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: McpAccessScreen(
          workspace: workspace, gardenClient: _FakeGardenClient(), client: mcp),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the garden\'s tokens and the endpoint', (tester) async {
    final mcp = client();
    await pump(tester, mcp);

    expect(mcp.listedGardens, ['g1']);
    expect(find.text('https://plantas.example/api/v1/mcp'), findsOneWidget);
    expect(find.text('Claude Desktop'), findsOneWidget);
    expect(find.textContaining('pmcp_aaaaaa… · Leitura e escrita'),
        findsOneWidget);
    expect(find.textContaining('Último uso em 11/10/2026'), findsOneWidget);
    // Someone else's token names its member; one's own doesn't.
    expect(find.textContaining('membro@x.com'), findsOneWidget);
    expect(find.textContaining('dona@x.com'), findsNothing);
    expect(find.textContaining('Nunca usado'), findsOneWidget);
  });

  testWidgets('creates a token and shows its secret once', (tester) async {
    final mcp = client();
    await pump(tester, mcp);
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Novo token'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' Claude Code ');
    await tester.tap(find.byType(Switch));
    await tester.tap(find.widgetWithText(FilledButton, 'Criar'));
    await tester.pumpAndSettle();

    expect(mcp.created, [(name: 'Claude Code', canWrite: true)]);
    expect(find.text('Token criado'), findsOneWidget);
    expect(find.text('pmcp_newnew_secret'), findsOneWidget);
    expect(
        find.textContaining('claude mcp add --transport http polypodium '
            'https://plantas.example/api/v1/mcp'),
        findsOneWidget);

    await tester.tap(find.byTooltip('Copiar').at(1));
    await tester.pumpAndSettle();
    expect(copied, 'pmcp_newnew_secret');

    await tester.tap(find.text('Pronto'));
    await tester.pumpAndSettle();
    expect(find.text('pmcp_newnew_secret'), findsNothing);
    expect(find.text('Claude Code'), findsOneWidget);
  });

  testWidgets('with MCP off on the server it says so and offers no new token',
      (tester) async {
    await pump(tester, client(enabled: false));

    expect(find.text('O acesso por MCP está desligado neste servidor.'),
        findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    // Existing tokens can still be revoked.
    expect(find.byTooltip('Revogar Cursor'), findsOneWidget);
  });

  testWidgets('revokes after confirming', (tester) async {
    final mcp = client();
    await pump(tester, mcp);

    await tester.tap(find.byTooltip('Revogar Cursor'));
    await tester.pumpAndSettle();
    expect(find.text('Revogar token?'), findsOneWidget);
    await tester.tap(find.text('Revogar'));
    await tester.pumpAndSettle();

    expect(mcp.revoked, ['theirs']);
    expect(find.text('Cursor'), findsNothing);
  });

  group('accessibility', () {
    for (final (name, theme) in appThemes) {
      testWidgets('meets the guidelines ($name)', (tester) async {
        await pump(tester, client(), theme: theme);
        await expectTapTargetGuidelines(tester);
        await expectReadableText(tester);
      });

      testWidgets('the disabled notice meets the guidelines ($name)',
          (tester) async {
        await pump(tester, client(enabled: false), theme: theme);
        await expectTapTargetGuidelines(tester);
        await expectReadableText(tester);
      });
    }

    testWidgets('large text does not overflow', (tester) async {
      setTextScale(tester, 2);
      await pump(tester, client());
      expect(tester.takeException(), isNull);
    });
  });
}
