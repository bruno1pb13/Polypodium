// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pending tasks of all active plants. Rebuilds when plants (last watering,
/// last pesticide) or reminders/entries change, so actions taken from the
/// agenda drop their row right away.

@ProviderFor(agendaTasks)
final agendaTasksProvider = AgendaTasksProvider._();

/// Pending tasks of all active plants. Rebuilds when plants (last watering,
/// last pesticide) or reminders/entries change, so actions taken from the
/// agenda drop their row right away.

final class AgendaTasksProvider extends $FunctionalProvider<
        AsyncValue<List<AgendaTask>>,
        List<AgendaTask>,
        FutureOr<List<AgendaTask>>>
    with $FutureModifier<List<AgendaTask>>, $FutureProvider<List<AgendaTask>> {
  /// Pending tasks of all active plants. Rebuilds when plants (last watering,
  /// last pesticide) or reminders/entries change, so actions taken from the
  /// agenda drop their row right away.
  AgendaTasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'agendaTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$agendaTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<AgendaTask>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<AgendaTask>> create(Ref ref) {
    return agendaTasks(ref);
  }
}

String _$agendaTasksHash() => r'4ac703b3d481ce0a9bd87cbfaaf8223506b4f1f0';

/// Number of overdue and due-today tasks, for the navigation badge.

@ProviderFor(agendaDueCount)
final agendaDueCountProvider = AgendaDueCountProvider._();

/// Number of overdue and due-today tasks, for the navigation badge.

final class AgendaDueCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Number of overdue and due-today tasks, for the navigation badge.
  AgendaDueCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'agendaDueCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$agendaDueCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return agendaDueCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$agendaDueCountHash() => r'232cbcf551fd12340f947ac424f303d1000b99e7';
