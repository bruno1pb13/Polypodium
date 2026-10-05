import 'package:flutter/material.dart';

import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/plants/domain/plant_model.dart';
import '../../features/plants/presentation/screens/plant_detail_screen.dart';
import '../l10n/l10n.dart';
import 'app_link.dart';

/// Looks a plant up in the active workspace.
typedef PlantLookup = Future<PlantModel?> Function(String plantId);

/// The screen a link to a plant opens.
typedef PlantScreenBuilder = Widget Function(String plantId);

Widget _plantDetail(String plantId) => PlantDetailScreen(plantId: plantId);

/// Opens the links that launch or reach the running app: home-screen widget
/// taps (agenda, plant) and plant labels scanned with the system camera.
class AppLinkHandler {
  AppLinkHandler(this.navigatorKey, this.findPlant,
      {this.plantScreen = _plantDetail});

  final GlobalKey<NavigatorState> navigatorKey;
  final PlantLookup findPlant;
  final PlantScreenBuilder plantScreen;

  void handle(Uri? uri, {bool retry = true}) {
    final link = AppLink.parse(uri);
    if (link == null ||
        (link.type != AppLinkType.agenda && link.type != AppLinkType.plant)) {
      return;
    }
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      // App launched by the link: the navigator exists after the first frame.
      if (retry) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => handle(uri, retry: false));
      }
      return;
    }
    if (link.type == AppLinkType.agenda) {
      navigator.push(MaterialPageRoute(builder: (_) => const AgendaScreen()));
    } else {
      openLinkedPlant(navigator, link.plantId!, findPlant,
          plantScreen: plantScreen);
    }
  }
}

/// Opens the plant [plantId] when it exists in the active workspace;
/// otherwise says so in a snack bar.
Future<void> openLinkedPlant(
  NavigatorState navigator,
  String plantId,
  PlantLookup findPlant, {
  PlantScreenBuilder plantScreen = _plantDetail,
}) async {
  final plant = await findPlant(plantId);
  if (!navigator.mounted) return;
  if (plant == null || plant.deletedAt != null) {
    _showMessage(
        navigator, AppLocalizations.of(navigator.context).labelPlantNotFound);
    return;
  }
  navigator.push(MaterialPageRoute(builder: (_) => plantScreen(plantId)));
}

/// Opens the plant a code read by the in-app scanner points to.
Future<void> openScannedLabel(
  NavigatorState navigator,
  String code,
  PlantLookup findPlant, {
  PlantScreenBuilder plantScreen = _plantDetail,
}) async {
  final link = AppLink.tryParse(code);
  if (link == null || link.type != AppLinkType.plant) {
    _showMessage(
        navigator, AppLocalizations.of(navigator.context).labelScanInvalid);
    return;
  }
  await openLinkedPlant(navigator, link.plantId!, findPlant,
      plantScreen: plantScreen);
}

void _showMessage(NavigatorState navigator, String message) {
  ScaffoldMessenger.maybeOf(navigator.context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
