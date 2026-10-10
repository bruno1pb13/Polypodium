// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_update_notice.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tells admins of the active workspace's server that it is behind the
/// newest release. Only a notice: updating the server is done outside the
/// app. Refreshed whenever the app opens or resumes and when the active
/// workspace changes; failures (offline, old server) stay silent.

@ProviderFor(ServerUpdateNotice)
final serverUpdateNoticeProvider = ServerUpdateNoticeProvider._();

/// Tells admins of the active workspace's server that it is behind the
/// newest release. Only a notice: updating the server is done outside the
/// app. Refreshed whenever the app opens or resumes and when the active
/// workspace changes; failures (offline, old server) stay silent.
final class ServerUpdateNoticeProvider
    extends $NotifierProvider<ServerUpdateNotice, ServerUpdateNoticeState?> {
  /// Tells admins of the active workspace's server that it is behind the
  /// newest release. Only a notice: updating the server is done outside the
  /// app. Refreshed whenever the app opens or resumes and when the active
  /// workspace changes; failures (offline, old server) stay silent.
  ServerUpdateNoticeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serverUpdateNoticeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serverUpdateNoticeHash();

  @$internal
  @override
  ServerUpdateNotice create() => ServerUpdateNotice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerUpdateNoticeState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerUpdateNoticeState?>(value),
    );
  }
}

String _$serverUpdateNoticeHash() =>
    r'8c89f47b17350943048a3fcae40c7c12beac1b95';

/// Tells admins of the active workspace's server that it is behind the
/// newest release. Only a notice: updating the server is done outside the
/// app. Refreshed whenever the app opens or resumes and when the active
/// workspace changes; failures (offline, old server) stay silent.

abstract class _$ServerUpdateNotice
    extends $Notifier<ServerUpdateNoticeState?> {
  ServerUpdateNoticeState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ServerUpdateNoticeState?, ServerUpdateNoticeState?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ServerUpdateNoticeState?, ServerUpdateNoticeState?>,
        ServerUpdateNoticeState?,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
