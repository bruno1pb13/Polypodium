import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'core/database/database_provider.dart';
import 'core/links/app_link_handler.dart';
import 'core/notifications/notification_response_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/sync/auto_sync_controller.dart';
import 'core/sync/background_sync.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'core/widgets/sync_status_banner.dart';
import 'features/agenda/data/home_widget_service.dart';
import 'features/agenda/presentation/providers/home_widget_providers.dart';
import 'features/onboarding/presentation/screens/intro_screen.dart';
import 'features/plants/presentation/providers/plants_providers.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/workspaces/data/workspace_repository.dart';

/// Background entry point for WorkManager tasks (Android only).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == NotificationService.irrigationCheckTask) {
      await NotificationService.checkAndRescheduleAll(
          beforeReschedule: BackgroundSync.runForActiveWorkspace);
    }
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Created up front (instead of by ProviderScope) so notification taps and
  // actions can reach the providers outside the widget tree.
  final container = ProviderContainer();
  final notificationResponses =
      NotificationResponseHandler(container, GlobalKey<NavigatorState>());
  await NotificationService.initialize(
      onResponse: notificationResponses.handle);

  final prefs = await SharedPreferences.getInstance();
  await WorkspaceRepository(prefs).ensureBootstrapped();
  final showIntro = !SettingsRepository(prefs).hasSeenIntro();

  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher);
    // No network constraint: the reminder reschedule must also run offline,
    // where the sync pass that precedes it just fails fast.
    await Workmanager().registerPeriodicTask(
      'irrigation-check',
      NotificationService.irrigationCheckTask,
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    await _guard(() =>
        HomeWidget.registerInteractivityCallback(onHomeWidgetInteraction));
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: PolypodiumApp(
      showIntro: showIntro,
      navigatorKey: notificationResponses.navigatorKey,
    ),
  ));

  // A tap that launched the app never reaches the response callback. On the
  // first launch (intro) there is no reminder worth opening yet.
  final launchResponse = await NotificationService.launchResponse();
  if (launchResponse != null && !showIntro) {
    await notificationResponses.handle(launchResponse);
  }

  // polypodium:// links that open the app: home-screen widget taps and
  // plant labels scanned with the system camera. The stream also delivers
  // the link that launched the app, if any.
  if ((Platform.isAndroid || Platform.isIOS) && !showIntro) {
    final links = AppLinkHandler(notificationResponses.navigatorKey,
        (id) => container.read(plantsRepositoryProvider).getById(id));
    AppLinks().uriLinkStream.listen(links.handle, onError: (_) {});
  }
}

/// The home-screen widget is an extra: a plugin failure must not stop the
/// app from starting.
Future<void> _guard(Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    // ignore: avoid_print
    print('[HomeWidget] $e');
  }
}

class PolypodiumApp extends ConsumerWidget {
  const PolypodiumApp({super.key, this.showIntro = false, this.navigatorKey});

  /// Whether to show the first-launch introduction instead of the app shell.
  final bool showIntro;

  /// Lets notification taps navigate from outside the widget tree.
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeStr = ref.watch(themeModeNotifierProvider);

    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Polypodium',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Locale is resolved automatically from the device language; English
      // is the fallback for any language other than Portuguese.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: showIntro ? const IntroScreen() : const AppShell(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => _AutoSyncScope(child: child!),
    );
  }
}

/// Wraps the whole app (above the Navigator) so the sync status banner
/// shows on top of any screen, and triggers a sync attempt whenever the app
/// is opened or comes back to the foreground.
class _AutoSyncScope extends ConsumerStatefulWidget {
  const _AutoSyncScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_AutoSyncScope> createState() => _AutoSyncScopeState();
}

class _AutoSyncScopeState extends ConsumerState<_AutoSyncScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerSync());
    // Listened, not read: an unlistened provider's own listeners are paused.
    if (Platform.isAndroid) {
      ref.listenManual(homeWidgetSyncProvider, (_, __) {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Notification actions ("Watered") write to the database from another
      // isolate, invisible to this isolate's Drift streams: re-run them.
      final db = ref.read(appDatabaseProvider);
      db.markTablesUpdated(db.allTables);
      _triggerSync();
    }
  }

  void _triggerSync() {
    ref.read(autoSyncControllerProvider.notifier).syncNow();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SyncStatusBanner(),
        Expanded(child: widget.child),
      ],
    );
  }
}
