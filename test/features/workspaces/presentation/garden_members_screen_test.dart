import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/sync/sync_exceptions.dart';
import 'package:polypodium/features/workspaces/data/garden_client.dart';
import 'package:polypodium/features/workspaces/domain/garden.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/screens/garden_members_screen.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeGardenClient implements GardenClient {
  _FakeGardenClient({
    required this.gardens,
    required this.members,
    this.listError,
  });

  final List<Garden> gardens;
  final List<GardenMember> members;
  final Object? listError;
  final added = <String>[];
  final removed = <String>[];
  Object? addError;

  @override
  Future<List<Garden>> listGardens(
      {required String serverUrl, required String token}) async {
    if (listError != null) throw listError!;
    return gardens;
  }

  @override
  Future<List<GardenMember>> listMembers(
          {required String serverUrl,
          required String token,
          required String gardenId}) async =>
      List.of(members);

  @override
  Future<void> addMember(
      {required String serverUrl,
      required String token,
      required String gardenId,
      required String email}) async {
    if (addError != null) throw addError!;
    added.add(email);
    members.add(GardenMember(userId: 'new', email: email, role: 'member'));
  }

  @override
  Future<void> removeMember(
      {required String serverUrl,
      required String token,
      required String gardenId,
      required String userId}) async {
    removed.add(userId);
    members.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<Garden> createGarden(
          {required String serverUrl,
          required String token,
          required String name}) =>
      throw UnimplementedError();
}

void main() {
  const owner = GardenMember(userId: 'u1', email: 'dona@x.com', role: 'owner');
  const member =
      GardenMember(userId: 'u2', email: 'membro@x.com', role: 'member');

  const shared = Garden(
      id: 'g1',
      name: 'Horta',
      personal: false,
      role: 'owner',
      ownerEmail: 'dona@x.com');

  Workspace workspace(String email) => Workspace(
        id: 'w1',
        name: 'Horta',
        type: WorkspaceType.remote,
        serverUrl: 'https://plantas.example',
        userEmail: email,
        token: 't',
        deviceId: 'd',
        createdAt: DateTime(2026, 1, 1),
        gardenId: 'g1',
        gardenName: 'Horta',
      );

  _FakeGardenClient ownerClient() =>
      _FakeGardenClient(gardens: [shared], members: [owner, member]);

  _FakeGardenClient memberClient() => _FakeGardenClient(gardens: [
        const Garden(
            id: 'g1',
            name: 'Horta',
            personal: false,
            role: 'member',
            ownerEmail: 'dona@x.com'),
      ], members: [
        owner,
        member
      ]);

  bool? popped;

  Future<void> pump(WidgetTester tester, Workspace ws, GardenClient client,
      {ThemeData? theme}) async {
    popped = null;
    // Start from scratch when a test opens the screen more than once.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              popped = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        GardenMembersScreen(workspace: ws, client: client)),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('owner', () {
    testWidgets('sees every member and can remove members, not themself',
        (tester) async {
      final client = ownerClient();
      await pump(tester, workspace('dona@x.com'), client);

      expect(find.text('Horta'), findsOneWidget);
      expect(find.text('Você é o dono deste jardim'), findsOneWidget);
      expect(find.text('dona@x.com (você)'), findsOneWidget);
      expect(find.text('membro@x.com'), findsOneWidget);
      expect(find.byTooltip('Remover membro@x.com'), findsOneWidget);
      expect(find.byTooltip('Remover dona@x.com'), findsNothing);
      expect(find.text('Sair do jardim'), findsNothing);

      await tester.tap(find.byTooltip('Remover membro@x.com'));
      await tester.pumpAndSettle();
      expect(find.text('Remover membro?'), findsOneWidget);
      await tester.tap(find.text('Remover'));
      await tester.pumpAndSettle();

      expect(client.removed, ['u2']);
      expect(find.text('membro@x.com'), findsNothing);
    });

    testWidgets('cancelling the removal keeps the member', (tester) async {
      final client = ownerClient();
      await pump(tester, workspace('dona@x.com'), client);

      await tester.tap(find.byTooltip('Remover membro@x.com'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(client.removed, isEmpty);
      expect(find.text('membro@x.com'), findsOneWidget);
    });

    testWidgets('adds a member by e-mail', (tester) async {
      final client = ownerClient();
      await pump(tester, workspace('dona@x.com'), client);

      await tester
          .tap(find.widgetWithText(FloatingActionButton, 'Adicionar membro'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' nova@x.com ');
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar membro'));
      await tester.pumpAndSettle();

      expect(client.added, ['nova@x.com']);
      expect(find.text('nova@x.com'), findsOneWidget);
      expect(find.text('nova@x.com adicionado(a).'), findsOneWidget);
    });

    testWidgets('an unknown e-mail is explained', (tester) async {
      final client = ownerClient()
        ..addError = const GardenAccountNotFoundException();
      await pump(tester, workspace('dona@x.com'), client);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ninguem@x.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar membro'));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma conta com esse e-mail neste servidor.'),
          findsOneWidget);
    });
  });

  group('member', () {
    testWidgets('sees the members but cannot manage them', (tester) async {
      await pump(tester, workspace('membro@x.com'), memberClient());

      expect(find.text('Você é membro deste jardim'), findsOneWidget);
      expect(find.text('membro@x.com (você)'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byIcon(Icons.person_remove_outlined), findsNothing);
      expect(find.text('Sair do jardim'), findsOneWidget);
    });

    testWidgets('can leave the garden', (tester) async {
      final client = memberClient();
      await pump(tester, workspace('membro@x.com'), client);

      await tester.tap(find.text('Sair do jardim'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Sair do jardim'));
      await tester.pumpAndSettle();

      expect(client.removed, ['u2']);
      expect(popped, isTrue);
    });
  });

  testWidgets('the personal garden of a workspace without a garden id',
      (tester) async {
    final client = _FakeGardenClient(gardens: [
      const Garden(id: 'u1', name: '', personal: true, role: 'owner'),
      shared,
    ], members: [
      owner
    ]);
    await pump(
        tester, workspace('dona@x.com').copyWith(gardenId: null), client);

    expect(find.text('Jardim pessoal'), findsOneWidget);
  });

  testWidgets('a server predating gardens says so', (tester) async {
    await pump(
        tester,
        workspace('dona@x.com'),
        _FakeGardenClient(
            gardens: const [],
            members: const [],
            listError: const GardensUnsupportedException()));

    expect(find.textContaining('ainda não suporta jardins'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('a garden the account left is reported as lost access',
      (tester) async {
    await pump(tester, workspace('dona@x.com'),
        _FakeGardenClient(gardens: const [], members: const []));

    expect(find.text('Você não é mais membro deste jardim.'), findsOneWidget);
  });

  group('accessibility', () {
    for (final (name, theme) in appThemes) {
      testWidgets('owner view meets the guidelines ($name)', (tester) async {
        await pump(tester, workspace('dona@x.com'), ownerClient(),
            theme: theme);
        await expectTapTargetGuidelines(tester);
        await expectReadableText(tester);
      });

      testWidgets('member view meets the guidelines ($name)', (tester) async {
        await pump(tester, workspace('membro@x.com'), memberClient(),
            theme: theme);
        await expectTapTargetGuidelines(tester);
        await expectReadableText(tester);
      });
    }

    testWidgets('large text does not overflow', (tester) async {
      setTextScale(tester, 2);
      await pump(tester, workspace('dona@x.com'), ownerClient());
      expect(tester.takeException(), isNull);
      await pump(tester, workspace('membro@x.com'), memberClient());
      expect(tester.takeException(), isNull);
    });
  });
}
