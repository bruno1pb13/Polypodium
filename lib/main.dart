import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'core/notifications/notification_service.dart';
import 'core/sync/auto_sync_controller.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'core/widgets/sync_status_banner.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/workspaces/data/workspace_repository.dart';

/// Background entry point for WorkManager tasks (Android only).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // TODO(sync): Add background sync trigger here alongside notification check
    if (taskName == NotificationService.irrigationCheckTask) {
      await NotificationService.checkAndRescheduleAll();
    }
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  await WorkspaceRepository(prefs).ensureBootstrapped();

  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      'irrigation-check',
      NotificationService.irrigationCheckTask,
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  runApp(const ProviderScope(child: PolypodiumApp()));
}

class PolypodiumApp extends ConsumerWidget {
  const PolypodiumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeStr = ref.watch(themeModeNotifierProvider);

    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Polypodium',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Locale is resolved automatically from the device language; English
      // is the fallback for any language other than Portuguese.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppShell(),
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _triggerSync();
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
