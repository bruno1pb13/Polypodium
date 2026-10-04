// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminders_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remindersRepository)
final remindersRepositoryProvider = RemindersRepositoryProvider._();

final class RemindersRepositoryProvider extends $FunctionalProvider<
    RemindersRepository,
    RemindersRepository,
    RemindersRepository> with $Provider<RemindersRepository> {
  RemindersRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'remindersRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$remindersRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemindersRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RemindersRepository create(Ref ref) {
    return remindersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemindersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemindersRepository>(value),
    );
  }
}

String _$remindersRepositoryHash() =>
    r'3e46e808cb3b102a91570efd02c55037d2034254';

/// A plant's reminders with their derived due dates. Re-emits when an entry
/// of the plant is created or deleted, which moves the due date.

@ProviderFor(plantReminders)
final plantRemindersProvider = PlantRemindersFamily._();

/// A plant's reminders with their derived due dates. Re-emits when an entry
/// of the plant is created or deleted, which moves the due date.

final class PlantRemindersProvider extends $FunctionalProvider<
        AsyncValue<List<ReminderStatus>>,
        List<ReminderStatus>,
        Stream<List<ReminderStatus>>>
    with
        $FutureModifier<List<ReminderStatus>>,
        $StreamProvider<List<ReminderStatus>> {
  /// A plant's reminders with their derived due dates. Re-emits when an entry
  /// of the plant is created or deleted, which moves the due date.
  PlantRemindersProvider._(
      {required PlantRemindersFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'plantRemindersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantRemindersHash();

  @override
  String toString() {
    return r'plantRemindersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReminderStatus>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ReminderStatus>> create(Ref ref) {
    final argument = this.argument as String;
    return plantReminders(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlantRemindersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$plantRemindersHash() => r'd80717532eee08de8814992f6e020cb901631af5';

/// A plant's reminders with their derived due dates. Re-emits when an entry
/// of the plant is created or deleted, which moves the due date.

final class PlantRemindersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReminderStatus>>, String> {
  PlantRemindersFamily._()
      : super(
          retry: null,
          name: r'plantRemindersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// A plant's reminders with their derived due dates. Re-emits when an entry
  /// of the plant is created or deleted, which moves the due date.

  PlantRemindersProvider call(
    String plantId,
  ) =>
      PlantRemindersProvider._(argument: plantId, from: this);

  @override
  String toString() => r'plantRemindersProvider';
}

/// Every active reminder across all plants (enabled or not), for the agenda.

@ProviderFor(allReminders)
final allRemindersProvider = AllRemindersProvider._();

/// Every active reminder across all plants (enabled or not), for the agenda.

final class AllRemindersProvider extends $FunctionalProvider<
        AsyncValue<List<ReminderStatus>>,
        List<ReminderStatus>,
        Stream<List<ReminderStatus>>>
    with
        $FutureModifier<List<ReminderStatus>>,
        $StreamProvider<List<ReminderStatus>> {
  /// Every active reminder across all plants (enabled or not), for the agenda.
  AllRemindersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allRemindersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allRemindersHash();

  @$internal
  @override
  $StreamProviderElement<List<ReminderStatus>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ReminderStatus>> create(Ref ref) {
    return allReminders(ref);
  }
}

String _$allRemindersHash() => r'8a6fadc744103bd3c4e6f9badb1e3bd2728569b0';

@ProviderFor(reminderMutations)
final reminderMutationsProvider = ReminderMutationsProvider._();

final class ReminderMutationsProvider extends $FunctionalProvider<
    ReminderMutations,
    ReminderMutations,
    ReminderMutations> with $Provider<ReminderMutations> {
  ReminderMutationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reminderMutationsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reminderMutationsHash();

  @$internal
  @override
  $ProviderElement<ReminderMutations> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReminderMutations create(Ref ref) {
    return reminderMutations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderMutations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderMutations>(value),
    );
  }
}

String _$reminderMutationsHash() => r'bbe9fff9745ce328fe5793fcbb72ff07231de591';
