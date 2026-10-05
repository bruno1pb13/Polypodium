import 'package:flutter/material.dart';

import '../../plants/presentation/screens/plant_detail_screen.dart';
import '../data/home_widget_service.dart';
import 'screens/agenda_screen.dart';

/// Opens what a home-screen widget tap asks for: the agenda (header) or a
/// plant (one of its rows).
class HomeWidgetLaunchHandler {
  HomeWidgetLaunchHandler(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  void handle(Uri? uri, {bool retry = true}) {
    final link = HomeWidgetLink.parse(uri);
    final Widget screen;
    switch (link?.type) {
      case HomeWidgetLinkType.agenda:
        screen = const AgendaScreen();
      case HomeWidgetLinkType.plant:
        screen = PlantDetailScreen(plantId: link!.plantId!);
      default:
        return;
    }
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      // App launched by the tap: the navigator exists after the first frame.
      if (retry) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => handle(uri, retry: false));
      }
      return;
    }
    navigator.push(MaterialPageRoute(builder: (_) => screen));
  }
}
