// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminClient)
final adminClientProvider = AdminClientProvider._();

final class AdminClientProvider
    extends $FunctionalProvider<AdminClient, AdminClient, AdminClient>
    with $Provider<AdminClient> {
  AdminClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'adminClientProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$adminClientHash();

  @$internal
  @override
  $ProviderElement<AdminClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminClient create(Ref ref) {
    return adminClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminClient>(value),
    );
  }
}

String _$adminClientHash() => r'98d221cec6aa90c91ce4208cd24cebc8e55e64c3';

@ProviderFor(serverStatus)
final serverStatusProvider = ServerStatusFamily._();

final class ServerStatusProvider extends $FunctionalProvider<
        AsyncValue<ServerStatus>, ServerStatus, FutureOr<ServerStatus>>
    with $FutureModifier<ServerStatus>, $FutureProvider<ServerStatus> {
  ServerStatusProvider._(
      {required ServerStatusFamily super.from,
      required Workspace super.argument})
      : super(
          retry: null,
          name: r'serverStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serverStatusHash();

  @override
  String toString() {
    return r'serverStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ServerStatus> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ServerStatus> create(Ref ref) {
    final argument = this.argument as Workspace;
    return serverStatus(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ServerStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverStatusHash() => r'2f581a8be621fbe60430e528bcabf5bcb9615f66';

final class ServerStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ServerStatus>, Workspace> {
  ServerStatusFamily._()
      : super(
          retry: null,
          name: r'serverStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ServerStatusProvider call(
    Workspace workspace,
  ) =>
      ServerStatusProvider._(argument: workspace, from: this);

  @override
  String toString() => r'serverStatusProvider';
}

@ProviderFor(ServerUsersNotifier)
final serverUsersNotifierProvider = ServerUsersNotifierFamily._();

final class ServerUsersNotifierProvider
    extends $AsyncNotifierProvider<ServerUsersNotifier, List<ServerUser>> {
  ServerUsersNotifierProvider._(
      {required ServerUsersNotifierFamily super.from,
      required Workspace super.argument})
      : super(
          retry: null,
          name: r'serverUsersNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serverUsersNotifierHash();

  @override
  String toString() {
    return r'serverUsersNotifierProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ServerUsersNotifier create() => ServerUsersNotifier();

  @override
  bool operator ==(Object other) {
    return other is ServerUsersNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverUsersNotifierHash() =>
    r'9094a0367d00883f3134295ce3f50b370998f229';

final class ServerUsersNotifierFamily extends $Family
    with
        $ClassFamilyOverride<ServerUsersNotifier, AsyncValue<List<ServerUser>>,
            List<ServerUser>, FutureOr<List<ServerUser>>, Workspace> {
  ServerUsersNotifierFamily._()
      : super(
          retry: null,
          name: r'serverUsersNotifierProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ServerUsersNotifierProvider call(
    Workspace workspace,
  ) =>
      ServerUsersNotifierProvider._(argument: workspace, from: this);

  @override
  String toString() => r'serverUsersNotifierProvider';
}

abstract class _$ServerUsersNotifier extends $AsyncNotifier<List<ServerUser>> {
  late final _$args = ref.$arg as Workspace;
  Workspace get workspace => _$args;

  FutureOr<List<ServerUser>> build(
    Workspace workspace,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ServerUser>>, List<ServerUser>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ServerUser>>, List<ServerUser>>,
        AsyncValue<List<ServerUser>>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
