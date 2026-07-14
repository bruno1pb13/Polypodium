// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider extends $FunctionalProvider<
    SettingsRepository,
    SettingsRepository,
    SettingsRepository> with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'02bf8401c2dfd788c76e465b8e8084ceb2ecae98';

@ProviderFor(NotificationsEnabledNotifier)
final notificationsEnabledNotifierProvider =
    NotificationsEnabledNotifierProvider._();

final class NotificationsEnabledNotifierProvider
    extends $NotifierProvider<NotificationsEnabledNotifier, bool> {
  NotificationsEnabledNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationsEnabledNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationsEnabledNotifierHash();

  @$internal
  @override
  NotificationsEnabledNotifier create() => NotificationsEnabledNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$notificationsEnabledNotifierHash() =>
    r'a2c339c527964d4a7e73b35554641657b1a8354d';

abstract class _$NotificationsEnabledNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(NotificationTimeNotifier)
final notificationTimeNotifierProvider = NotificationTimeNotifierProvider._();

final class NotificationTimeNotifierProvider
    extends $NotifierProvider<NotificationTimeNotifier, TimeOfDay> {
  NotificationTimeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationTimeNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationTimeNotifierHash();

  @$internal
  @override
  NotificationTimeNotifier create() => NotificationTimeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeOfDay value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeOfDay>(value),
    );
  }
}

String _$notificationTimeNotifierHash() =>
    r'65aa30e947b43f32d8af4a883cdfc5a3e5ba65ad';

abstract class _$NotificationTimeNotifier extends $Notifier<TimeOfDay> {
  TimeOfDay build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TimeOfDay, TimeOfDay>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TimeOfDay, TimeOfDay>, TimeOfDay, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TransparencyEnabledNotifier)
final transparencyEnabledNotifierProvider =
    TransparencyEnabledNotifierProvider._();

final class TransparencyEnabledNotifierProvider
    extends $NotifierProvider<TransparencyEnabledNotifier, bool> {
  TransparencyEnabledNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transparencyEnabledNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transparencyEnabledNotifierHash();

  @$internal
  @override
  TransparencyEnabledNotifier create() => TransparencyEnabledNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$transparencyEnabledNotifierHash() =>
    r'6f58bf7a2ca91afacb663938637ab16746cef5c3';

abstract class _$TransparencyEnabledNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider = ThemeModeNotifierProvider._();

final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, String> {
  ThemeModeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeModeNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'5eafcd88bf3a44a20ce6d13ecbb2f7ea4e592fe2';

abstract class _$ThemeModeNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(AutoSyncEnabledNotifier)
final autoSyncEnabledNotifierProvider = AutoSyncEnabledNotifierProvider._();

final class AutoSyncEnabledNotifierProvider
    extends $NotifierProvider<AutoSyncEnabledNotifier, bool> {
  AutoSyncEnabledNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'autoSyncEnabledNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$autoSyncEnabledNotifierHash();

  @$internal
  @override
  AutoSyncEnabledNotifier create() => AutoSyncEnabledNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoSyncEnabledNotifierHash() =>
    r'cf551a6bb7d6c5cf3a7dd3552871bc66736da581';

abstract class _$AutoSyncEnabledNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
