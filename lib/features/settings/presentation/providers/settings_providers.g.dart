// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = FutureProviderRef<SharedPreferences>;
String _$settingsRepositoryHash() =>
    r'02bf8401c2dfd788c76e465b8e8084ceb2ecae98';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = Provider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = ProviderRef<SettingsRepository>;
String _$notificationsEnabledNotifierHash() =>
    r'3ad1775d5a384ab11ec1fb8d3e657d0d7dfcda35';

/// See also [NotificationsEnabledNotifier].
@ProviderFor(NotificationsEnabledNotifier)
final notificationsEnabledNotifierProvider =
    AutoDisposeNotifierProvider<NotificationsEnabledNotifier, bool>.internal(
  NotificationsEnabledNotifier.new,
  name: r'notificationsEnabledNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsEnabledNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationsEnabledNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
