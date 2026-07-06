import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
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
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
