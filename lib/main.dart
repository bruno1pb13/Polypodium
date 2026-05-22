import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/plants/presentation/screens/home_screen.dart';

/// Background entry point for WorkManager tasks (must be a top-level function).
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

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'irrigation-check',
    NotificationService.irrigationCheckTask,
    frequency: const Duration(hours: 12),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );

  runApp(const ProviderScope(child: PlantLogApp()));
}

class PlantLogApp extends StatelessWidget {
  const PlantLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantLog',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
