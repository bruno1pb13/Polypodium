import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/l10n/l10n.dart';
import '../../data/home_widget_service.dart';
import '../../domain/agenda_task.dart';
import '../../domain/home_widget_snapshot.dart';
import 'agenda_providers.dart';

part 'home_widget_providers.g.dart';

@Riverpod(keepAlive: true)
HomeWidgetGateway homeWidgetGateway(Ref ref) =>
    const PlatformHomeWidgetGateway();

/// Keeps the home-screen widget in step with the agenda while the app runs:
/// every new agenda (an action, a sync pull, a workspace switch, the resume
/// refresh) republishes the snapshot. Listen to it to keep it running.
@Riverpod(keepAlive: true)
HomeWidgetSync homeWidgetSync(Ref ref) {
  final sync = HomeWidgetSync(ref.watch(homeWidgetGatewayProvider));
  ref.onDispose(sync.dispose);
  ref.listen(agendaTasksProvider, (_, next) {
    // Loading states keep the previous workspace's tasks: skip them.
    if (next case AsyncData(:final value)) sync.schedule(value);
  }, fireImmediately: true);
  return sync;
}

/// Debounces snapshot publishing: a burst of writes (watering every plant
/// from the agenda, a sync pull) redraws the widget once.
class HomeWidgetSync {
  HomeWidgetSync(
    this._gateway, {
    this.debounce = const Duration(seconds: 1),
    AppLocalizations Function()? l10n,
    DateTime Function()? now,
  })  : _l10n = l10n ?? systemL10n,
        _now = now ?? DateTime.now;

  final HomeWidgetGateway _gateway;
  final Duration debounce;
  final AppLocalizations Function() _l10n;
  final DateTime Function() _now;
  Timer? _timer;

  void schedule(List<AgendaTask> tasks) {
    _timer?.cancel();
    _timer = Timer(debounce, () {
      _gateway.publish(buildHomeWidgetSnapshot(tasks, _l10n(), now: _now()));
    });
  }

  void dispose() => _timer?.cancel();
}
