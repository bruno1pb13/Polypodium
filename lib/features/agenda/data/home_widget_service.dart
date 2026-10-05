import 'dart:convert';
import 'dart:io' show Platform;

import 'package:home_widget/home_widget.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/notifications/notification_service.dart';
import '../../plants/data/plants_repository.dart';
import '../../plants/domain/plant_model.dart';
import '../../reminders/data/reminders_repository.dart';
import '../../species/data/species_repository.dart';
import '../domain/agenda_task.dart';
import '../domain/home_widget_snapshot.dart';

/// Where the home-screen widget reads its content from.
abstract interface class HomeWidgetGateway {
  Future<void> publish(HomeWidgetSnapshot snapshot);
}

/// Stores the snapshot as JSON where the Android widget provider reads it
/// and redraws the widget. A no-op on every other platform.
class PlatformHomeWidgetGateway implements HomeWidgetGateway {
  const PlatformHomeWidgetGateway();

  /// Read by AgendaWidgetProvider.kt.
  static const snapshotKey = 'agenda_snapshot';

  /// Fully qualified: the application id differs from the Kotlin package, so
  /// the plugin can't resolve a bare class name.
  static const androidProvider =
      'com.polypodium.polypodium.AgendaWidgetProvider';

  @override
  Future<void> publish(HomeWidgetSnapshot snapshot) async {
    if (!Platform.isAndroid) return;
    try {
      await HomeWidget.saveWidgetData<String>(
          snapshotKey, jsonEncode(snapshot.toJson()));
      await HomeWidget.updateWidget(qualifiedAndroidName: androidProvider);
    } catch (e) {
      // ignore: avoid_print
      print('[HomeWidget] Failed to update the widget: $e');
    }
  }
}

/// The agenda read straight from [db], for isolates without Riverpod
/// (WorkManager, notification and widget actions). Same inputs as
/// agendaTasksProvider: plants with a known species and every reminder.
Future<List<AgendaTask>> loadAgendaTasks(AppDatabase db) async {
  final plants =
      await PlantsRepository(db, const NotificationService()).getAll();
  final speciesById = {
    for (final s in await SpeciesRepository(db).getAll()) s.id: s,
  };
  return buildAgendaTasks(
    plants: [
      for (final plant in plants)
        if (speciesById[plant.speciesId] case final species?)
          PlantWithSpecies(plant: plant, species: species),
    ],
    reminders: await RemindersRepository(db).getAllStatuses(),
  );
}

/// Recomputes the widget snapshot from [db] and publishes it.
Future<void> publishHomeWidgetFromDatabase(
  AppDatabase db, {
  HomeWidgetGateway gateway = const PlatformHomeWidgetGateway(),
  DateTime? now,
}) async {
  final tasks = await loadAgendaTasks(db);
  await gateway.publish(
      buildHomeWidgetSnapshot(tasks, systemL10n(), now: now ?? DateTime.now()));
}

/// The links the widget sends: [agenda] and [plant] open the app (launch
/// intents), [water] and [refresh] run in the background
/// ([onHomeWidgetInteraction]).
enum HomeWidgetLinkType { agenda, plant, water, refresh }

class HomeWidgetLink {
  const HomeWidgetLink(this.type, [this.plantId]);

  final HomeWidgetLinkType type;

  /// Set for [HomeWidgetLinkType.plant] and [HomeWidgetLinkType.water].
  final String? plantId;

  static const scheme = 'polypodium';

  /// polypodium://agenda, polypodium://plant?id=…, polypodium://water?id=…,
  /// polypodium://refresh. Null for anything else.
  static HomeWidgetLink? parse(Uri? uri) {
    if (uri == null || uri.scheme != scheme) return null;
    final type = HomeWidgetLinkType.values.asNameMap()[uri.host];
    if (type == null) return null;
    final id = uri.queryParameters['id'];
    final needsPlant =
        type == HomeWidgetLinkType.plant || type == HomeWidgetLinkType.water;
    if (needsPlant && (id == null || id.isEmpty)) return null;
    return HomeWidgetLink(type, needsPlant ? id : null);
  }
}

/// Runs in the widget's background isolate (started by the plugin) for the
/// "Watered" button and the stale-day refresh.
@pragma('vm:entry-point')
Future<void> onHomeWidgetInteraction(Uri? uri) async {
  final link = HomeWidgetLink.parse(uri);
  switch (link?.type) {
    case HomeWidgetLinkType.water:
      await NotificationService.handleWidgetAction(
          waterPlantIds: [link!.plantId!]);
    case HomeWidgetLinkType.refresh:
      await NotificationService.handleWidgetAction();
    default:
      break;
  }
}
