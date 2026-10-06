// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navMyPlants => 'My Plants';

  @override
  String get navAgenda => 'Agenda';

  @override
  String get navSpecies => 'Species';

  @override
  String get navLocations => 'Locations';

  @override
  String get navSoils => 'Soils';

  @override
  String get navDefensivos => 'Pesticides';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAction => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get create => 'Create';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get notNow => 'Not now';

  @override
  String get all => 'All';

  @override
  String get optional => 'Optional';

  @override
  String get requiredField => 'Required field';

  @override
  String get requiredShort => 'Required';

  @override
  String get unknown => 'Unknown';

  @override
  String get none => 'None';

  @override
  String get defaultValue => 'Default';

  @override
  String get notInformed => 'Not set';

  @override
  String get notAllowed => 'Not allowed.';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get share => 'Share';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get rename => 'Rename';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get migrate => 'Migrate';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get positiveNumberRequired => 'Enter a positive number';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get nameLabel => 'Name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get introSkip => 'Skip';

  @override
  String get introGetStarted => 'Get started';

  @override
  String get introWelcomeTitle => 'Welcome to Polypodium';

  @override
  String get introWelcomeBody =>
      'Your companion for caring for your plant collection.';

  @override
  String get introPlantsTitle => 'Track your plants';

  @override
  String get introPlantsBody =>
      'Register each plant with photos, species, location and soil, and keep its whole history in one place.';

  @override
  String get introRemindersTitle => 'Watering reminders';

  @override
  String get introRemindersBody =>
      'Get notified when it\'s time to water, based on each species\' needs.';

  @override
  String get introRemindersTimeLabel => 'Remind me at';

  @override
  String get introRemindersEnable => 'Turn on reminders';

  @override
  String get introRemindersEnabled => 'Reminders on!';

  @override
  String get introRemindersLaterNote =>
      'You can change this anytime in Settings.';

  @override
  String get introSyncTitle => 'Your data, everywhere';

  @override
  String get introSyncBody =>
      'Everything works offline. Connect to a server later to sync across devices and back up your data.';

  @override
  String get dateFormatPattern => 'M/d/yyyy';

  @override
  String daysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0';
  }

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String syncDownloaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count updates synced',
      one: '1 update synced',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline => 'No connection to the server — using local data';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing...';

  @override
  String get allSynced => 'Everything synced';

  @override
  String pendingEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending events',
      one: '$count pending event',
    );
    return '$_temp0';
  }

  @override
  String get autoSync => 'Automatic sync';

  @override
  String get autoSyncOnSubtitle =>
      'Every 5 minutes (30 in battery saver on Android)';

  @override
  String get autoSyncOffSubtitle => 'Disabled — sync manually';

  @override
  String get localWorkspaceNoSync => 'Local workspace — does not sync';

  @override
  String get manageWorkspaces => 'Manage workspaces';

  @override
  String get errorSessionExpired => 'Session expired. Please sign in again.';

  @override
  String get errorSyncReceive => 'Error receiving data from the server';

  @override
  String get errorSyncSend => 'Error sending data to the server';

  @override
  String get errorNotAuthenticated => 'Not authenticated';

  @override
  String get errorServerUnavailable => 'Server unavailable or invalid URL';

  @override
  String get errorAdminForbidden => 'You do not have administrator permission.';

  @override
  String get errorLoginFailed => 'Failed to sign in';

  @override
  String get errorRegisterFailed => 'Failed to create account';

  @override
  String get errorServerCommunication => 'Error communicating with the server';

  @override
  String get errorSpeciesInUse =>
      'A species with linked plants cannot be deleted.';

  @override
  String get errorSoilInUse => 'A soil with linked plants cannot be deleted.';

  @override
  String get locationUnsupportedPlatform =>
      'Geolocation is not supported on Linux desktop.';

  @override
  String get locationServiceDisabled =>
      'GPS is turned off. Enable it and try again.';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission permanently denied. Enable it in the device settings.';

  @override
  String locationFetchError(String error) {
    return 'Could not get the location: $error';
  }

  @override
  String get galleryPermissionDenied =>
      'Permission to access the gallery was denied';

  @override
  String get imageSavedToGallery => 'Image saved to gallery';

  @override
  String imageSaveError(String error) {
    return 'Error saving image: $error';
  }

  @override
  String shareError(String error) {
    return 'Error sharing: $error';
  }

  @override
  String get saveToGallery => 'Save to gallery';

  @override
  String get irrigationChannelName => 'Watering';

  @override
  String get irrigationChannelDescription =>
      'Watering reminders for your plants';

  @override
  String get irrigationNotificationTitle => 'Time to water! 🌿';

  @override
  String irrigationNotificationBody(String nickname) {
    return '$nickname needs to be watered today.';
  }

  @override
  String irrigationNotificationBodyMany(int count, String names) {
    return '$count plants need watering today: $names.';
  }

  @override
  String irrigationNotificationBodyCount(int count) {
    return '$count plants need water today.';
  }

  @override
  String get pesticideChannelName => 'Pesticides';

  @override
  String get pesticideChannelDescription => 'Pesticide reapplication reminders';

  @override
  String get pesticideNotificationTitle => 'Time to reapply! 🧪';

  @override
  String pesticideNotificationBody(String nickname) {
    return '$nickname needs a pesticide reapplication today.';
  }

  @override
  String pesticideNotificationBodyMany(int count, String names) {
    return '$count plants need reapplication today: $names.';
  }

  @override
  String pesticideNotificationBodyCount(int count) {
    return '$count plants need reapplication today.';
  }

  @override
  String get notificationActionWatered => 'Watered';

  @override
  String get notificationActionSnooze => 'Remind in 3 h';

  @override
  String get careChannelName => 'Other reminders';

  @override
  String get careChannelDescription =>
      'Recurring fertilizing, pruning and other care reminders';

  @override
  String careNotificationTitle(String type, String emoji) {
    return 'Reminder: $type $emoji';
  }

  @override
  String careNotificationBody(String nickname) {
    return 'Due today for $nickname.';
  }

  @override
  String careNotificationBodyMany(int count, String names) {
    return 'Due today for $count plants: $names.';
  }

  @override
  String careNotificationBodyCount(int count) {
    return 'Due today for $count plants.';
  }

  @override
  String get remindersSectionTitle => 'Reminders';

  @override
  String get remindersEmpty =>
      'No recurring reminders. Add one here, or fill in \"Repeat every\" when recording fertilizing, pruning, repotting or pesticide.';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get reminderTypeLabel => 'Care';

  @override
  String get reminderIntervalLabel => 'Every how many days';

  @override
  String get reminderIntervalInvalid =>
      'Enter a number of days between 1 and 365';

  @override
  String get reminderEnabledLabel => 'Enabled';

  @override
  String get reminderPaused => 'Paused';

  @override
  String reminderEvery(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Every $days days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String reminderNextDate(String date) {
    return 'Next: $date';
  }

  @override
  String reminderOverdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Overdue by $days days',
      one: 'Overdue by $days day',
    );
    return '$_temp0';
  }

  @override
  String reminderLastDone(String date) {
    return 'Last: $date';
  }

  @override
  String get reminderNeverDone => 'Not recorded yet';

  @override
  String get agendaOverdue => 'Overdue';

  @override
  String get agendaToday => 'Today';

  @override
  String agendaNextDays(int days) {
    return 'Next $days days';
  }

  @override
  String get agendaTomorrow => 'Tomorrow';

  @override
  String get agendaRecord => 'Record';

  @override
  String get agendaPesticideTask => 'Pesticide reapplication';

  @override
  String get agendaAllCaughtUp => 'All caught up! 🌿';

  @override
  String agendaAllCaughtUpHint(int days) {
    return 'No care due in the next $days days.';
  }

  @override
  String homeWidgetDueCount(int count) {
    return '$count due today';
  }

  @override
  String homeWidgetOverdue(int days) {
    return '$days d late';
  }

  @override
  String get homeWidgetToday => 'today';

  @override
  String homeWidgetMore(int count) {
    return '+$count more';
  }

  @override
  String get deleteReminderTitle => 'Delete reminder?';

  @override
  String get deleteReminderBody =>
      'The diary entries are kept; only the reminder is removed.';

  @override
  String get historyPlantAdded => 'Plant added to the system:';

  @override
  String get historyFieldNickname => 'Nickname';

  @override
  String get historyFieldSpecies => 'Species';

  @override
  String get historyFieldSoil => 'Soil';

  @override
  String get historyFieldLocation => 'Location';

  @override
  String get historyFieldAcquisitionDate => 'Acquisition date';

  @override
  String get historyFieldWateringFrequency => 'Watering frequency';

  @override
  String get historyAcquiredOn => 'Acquired on';

  @override
  String historyCustomWatering(String days) {
    return 'Custom watering: $days';
  }

  @override
  String get historyUpdatedHeader => 'Updated information:';

  @override
  String get searchPlantsHint => 'Search plants...';

  @override
  String get searchSpeciesHint => 'Search species...';

  @override
  String get searchSoilsHint => 'Search soils...';

  @override
  String get searchLocationsHint => 'Search locations...';

  @override
  String get sortWateringNeeds => 'Watering needs';

  @override
  String get sortNameAZ => 'Name (A-Z)';

  @override
  String get sortNameZA => 'Name (Z-A)';

  @override
  String get sortLastWatered => 'Last watered';

  @override
  String get sortDateAdded => 'Date added';

  @override
  String get sortPopularNameAZ => 'Popular Name (A-Z)';

  @override
  String get sortPopularNameZA => 'Popular Name (Z-A)';

  @override
  String get sortScientificNameAZ => 'Scientific Name (A-Z)';

  @override
  String get sortScientificNameZA => 'Scientific Name (Z-A)';

  @override
  String get sortNewestFirst => 'Newest first';

  @override
  String get sortOldestFirst => 'Oldest first';

  @override
  String get sortByType => 'By type';

  @override
  String get sortTooltip => 'Sort';

  @override
  String errorLoadingPlants(String error) {
    return 'Error loading plants: $error';
  }

  @override
  String get noPlantsFound => 'No plants found';

  @override
  String get noPlantsRegistered => 'No plants registered';

  @override
  String get allPlantsArchived => 'All plants are archived';

  @override
  String get allPlantsArchivedHint =>
      'Turn on \"Show archived\" in the menu to see them, or tap + to add a new plant.';

  @override
  String get tapToAddFirstPlant => 'Tap + to add your first plant.';

  @override
  String deletePlantsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count plants?',
      one: 'Delete $count plant?',
    );
    return '$_temp0';
  }

  @override
  String get deletePlantsBody => 'All records of these plants will be removed.';

  @override
  String get deletePlantTitle => 'Delete plant?';

  @override
  String get deletePlantBody => 'All records of this plant will be removed.';

  @override
  String get deletePlantArchiveHint =>
      'To keep its diary, consider archiving it instead.';

  @override
  String get deletePlantsArchiveHint =>
      'To keep their diaries, consider archiving them instead.';

  @override
  String get plantStatusActive => 'Active';

  @override
  String get plantStatusDead => 'Dead';

  @override
  String get plantStatusDonated => 'Donated';

  @override
  String get plantStatusArchived => 'Archived';

  @override
  String get plantStatusMarkDead => 'Mark as dead';

  @override
  String get plantStatusMarkDonated => 'Mark as donated';

  @override
  String get plantStatusArchive => 'Archive';

  @override
  String get plantStatusReactivate => 'Reactivate';

  @override
  String get plantStatusChange => 'Change status';

  @override
  String plantStatusSince(String status, String date) {
    return '$status since $date';
  }

  @override
  String get plantInactiveHint =>
      'No reminders while inactive. The diary is kept.';

  @override
  String get showArchivedPlants => 'Show archived';

  @override
  String get historyFieldStatus => 'Status';

  @override
  String get historyFieldParent => 'Cutting of';

  @override
  String speciesSurvivalRate(int total, int percent, int alive) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Survival: $percent% ($alive of $total plants)',
      one: 'Survival: $percent% ($alive of $total plant)',
    );
    return '$_temp0';
  }

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get deleteSelected => 'Delete selected';

  @override
  String get bulkEntryButton => 'Bulk entry';

  @override
  String get waterSelected => 'Water selected';

  @override
  String get bulkEntrySelected => 'Add entry for selected';

  @override
  String get waterAll => 'Water all';

  @override
  String irrigationRecordedForPlants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Watering recorded for $count plants',
      one: 'Watering recorded for $count plant',
    );
    return '$_temp0';
  }

  @override
  String get noPlantsAtLocation => 'No plants at this location';

  @override
  String get plantsAtLocationHint =>
      'Assign this location to a plant to see it here.';

  @override
  String get noPlantsOfSpecies => 'No plants of this species';

  @override
  String get plantsOfSpeciesHint =>
      'Add a plant of this species to see it here.';

  @override
  String get editPlant => 'Edit plant';

  @override
  String get newPlant => 'New plant';

  @override
  String get addPlant => 'Add plant';

  @override
  String get sectionIdentification => 'Identification';

  @override
  String get sectionCare => 'Care';

  @override
  String get sectionDetails => 'Details';

  @override
  String get sectionInformation => 'Information';

  @override
  String get sectionCoordinates => 'Coordinates';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameHint => 'E.g.: Living room fern';

  @override
  String get nicknameRequired => 'Enter a nickname';

  @override
  String get speciesRequired => 'Select a species';

  @override
  String get selectSpeciesFromList => 'Select a species from the list';

  @override
  String get selectSoilType => 'Select a soil type';

  @override
  String get newSoilType => 'New soil type';

  @override
  String get newLocation => 'New location';

  @override
  String get irrigationFrequencyLabel => 'Watering frequency (days)';

  @override
  String get irrigationFrequencyShort => 'Watering frequency';

  @override
  String get irrigationFrequencyHelper =>
      'If set, the app will send watering reminders.';

  @override
  String get recommendedSuffix => '(recommended)';

  @override
  String get locationLabel => 'Location';

  @override
  String get acquisitionDateLabel => 'Acquisition date';

  @override
  String get acquiredOnLabel => 'Acquired on';

  @override
  String get plantNotFound => 'Plant not found';

  @override
  String get soilLabel => 'Soil';

  @override
  String get needsWater => 'Needs water!';

  @override
  String get lastWateringNotRecorded => 'Last watering not recorded';

  @override
  String daysOverdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '$days day overdue',
    );
    return '$_temp0';
  }

  @override
  String get wateredNow => 'Watered now';

  @override
  String get irrigationRecorded => 'Watering recorded!';

  @override
  String irrigationRecordError(String error) {
    return 'Error recording watering: $error';
  }

  @override
  String get entriesTitle => 'Entries';

  @override
  String get entryTypesTitle => 'Entry types';

  @override
  String get filterTypes => 'Filter types';

  @override
  String get noEntriesFound => 'No entries found';

  @override
  String get deleteEntryTitle => 'Delete entry?';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String get severityActive => 'Active';

  @override
  String get pestBadge => 'Pest';

  @override
  String get pesticideActiveControlBadge => 'Pest control';

  @override
  String get pesticideReapplyBadge => 'Reapply';

  @override
  String get waterBadge => 'Water';

  @override
  String get dueToday => 'Due today';

  @override
  String nextPesticideApplication(String date) {
    return 'Next application: $date';
  }

  @override
  String get needsPesticideApplication => 'Apply pesticide!';

  @override
  String get pesticideApproachingTitle => 'Pesticide due soon';

  @override
  String nextPesticideInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Next application in $days days',
      one: 'Next application in $days day',
    );
    return '$_temp0';
  }

  @override
  String get entryTypeIrrigation => 'Watering';

  @override
  String get entryTypeFertilizer => 'Fertilizing';

  @override
  String get entryTypePruning => 'Pruning';

  @override
  String get entryTypeObservation => 'Observation';

  @override
  String get entryTypeHeight => 'Height';

  @override
  String get entryTypeChlorosis => 'Chlorosis';

  @override
  String get entryTypePest => 'Pests';

  @override
  String get entryTypePesticide => 'Pesticides';

  @override
  String get entryTypeOther => 'Other';

  @override
  String get entryTypeHistory => 'History';

  @override
  String get entryTypeRepotting => 'Repotting';

  @override
  String get newEntryTitle => 'New Entry';

  @override
  String newBulkEntryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'New entry ($count plants)',
      one: 'New entry ($count plant)',
    );
    return '$_temp0';
  }

  @override
  String get entryTypeCardTitle => 'Entry type';

  @override
  String get notesTitle => 'Notes';

  @override
  String get noteHintIrrigation => 'Anything in the water? Any observations?';

  @override
  String get noteHintFertilizer => 'Frequency, application method...';

  @override
  String get noteHintPruning => 'How was the plant before pruning?';

  @override
  String get noteHintObservation => 'How is the plant today?';

  @override
  String get noteHintHeight => 'Any observations about growth?';

  @override
  String get noteHintChlorosis => 'Which leaves are affected?';

  @override
  String get noteHintPest => 'Where was it found? Any treatment?';

  @override
  String get noteHintPesticide =>
      'Where was it applied? Any reaction from the plant?';

  @override
  String get noteHintRepotting => 'How were the roots? Was the plant divided?';

  @override
  String get noteHintDefault => 'Optional notes...';

  @override
  String get photoTitle => 'Photo';

  @override
  String get saveEntry => 'Save entry';

  @override
  String saveEntryForPlants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save for $count plants',
      one: 'Save for $count plant',
    );
    return '$_temp0';
  }

  @override
  String get pruningFormation => 'Formation';

  @override
  String get pruningCleaning => 'Cleaning';

  @override
  String get pruningRejuvenation => 'Rejuvenation';

  @override
  String get pruningHarvest => 'Harvest';

  @override
  String get pruningReasonHint => 'Reason (optional)';

  @override
  String get irrigationScarce => 'Scarce';

  @override
  String get irrigationScarceDesc => 'Soil slightly moist';

  @override
  String get irrigationModerate => 'Moderate';

  @override
  String get irrigationModerateDesc => 'Normal watering, soil well moistened';

  @override
  String get irrigationIntense => 'Intense';

  @override
  String get irrigationIntenseDesc => 'Soaked soil / long duration';

  @override
  String get irrigationIntensityHint => 'Watering intensity (optional)';

  @override
  String get fertilizerProductsHint => 'Product(s) used — optional';

  @override
  String get productLabel => 'Product';

  @override
  String get productHint => 'E.g.: Growth fertilizer';

  @override
  String get doseLabel => 'Dose';

  @override
  String get addProduct => 'Add product';

  @override
  String get pesticideProductsHint => 'Applied pesticide(s)';

  @override
  String get pesticideDoseLabel => 'Dose/Amount';

  @override
  String get pesticideDoseHint => 'E.g.: 2ml/L';

  @override
  String get addDefensivo => 'Add pesticide';

  @override
  String get defensivoRequired => 'Select a pesticide';

  @override
  String get pesticideRecurrenceLabel => 'Repeat application in (optional)';

  @override
  String get pesticideRecurrenceHint =>
      'Leave blank to skip the reapplication reminder.';

  @override
  String get entryReminderLabel => 'Repeat every (optional)';

  @override
  String get entryReminderHint =>
      'Creates or updates this care\'s reminder, shown under Reminders and in the agenda. Leave blank to keep it as is.';

  @override
  String get pesticideReminderInfoTitle => 'Pesticide reapplication';

  @override
  String get pesticideReminderInfoBody =>
      'This reminder comes from the latest pesticide entry. To change it, record a new application with another interval, or with none to end it.';

  @override
  String get pesticideReminderRecord => 'Record application';

  @override
  String get daysSuffix => 'days';

  @override
  String get healthScoreHint => 'Plant health score (optional)';

  @override
  String get healthCritical => 'Critical';

  @override
  String get healthBad => 'Bad';

  @override
  String get healthRegular => 'Fair';

  @override
  String get healthGood => 'Good';

  @override
  String get healthExcellent => 'Excellent';

  @override
  String healthSummary(int score) {
    return 'Health $score/5';
  }

  @override
  String get heightSectionTitle => 'Plant height';

  @override
  String get heightCmLabel => 'Height in cm';

  @override
  String get heightHint => 'E.g.: 32.5';

  @override
  String get heightInvalid => 'Enter a valid height in cm';

  @override
  String get heightMeasureHint =>
      'Measure from soil level to the tallest leaf.';

  @override
  String get severitySelectHint => 'Select the severity *';

  @override
  String get chlorosisCured => 'Cured';

  @override
  String get chlorosisCuredDesc => 'Plant with no active chlorosis';

  @override
  String get chlorosisMildDesc => 'Few yellowing leaves';

  @override
  String get chlorosisModerateDesc => 'Several leaves affected';

  @override
  String get chlorosisSevereDesc => 'Most leaves affected';

  @override
  String get pestTypeLabel => 'Pest type';

  @override
  String get pestTypeHint => 'E.g.: Mealybug, Aphid, Mite...';

  @override
  String get pestTypeRequired => 'Enter the pest type';

  @override
  String get pestSeverityHint => 'Infestation severity *';

  @override
  String get pestEradicated => 'Eradicated';

  @override
  String get pestEradicatedDesc => 'Plant free of pests';

  @override
  String get pestMildDesc => 'Few individuals / small area';

  @override
  String get pestModerateDesc => 'Several areas affected';

  @override
  String get pestSevereDesc => 'Widespread infestation';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '$count product',
    );
    return '$_temp0';
  }

  @override
  String get viewDiary => 'Diary';

  @override
  String get viewCharts => 'Charts';

  @override
  String get viewPhotos => 'Photos';

  @override
  String get chartGrowthTitle => 'Growth';

  @override
  String get chartHealthTitle => 'Overall health';

  @override
  String get chartWateringTitle => 'Watering regularity';

  @override
  String get chartNeedTwoHeights =>
      'Record the height at least twice to see the growth curve.';

  @override
  String get chartNeedTwoHealth =>
      'Record observations with a health score to see the trend.';

  @override
  String get chartNeedTwoWaterings =>
      'Record at least two waterings to see the intervals.';

  @override
  String get chartsEmpty =>
      'No chart data yet. Log heights, health scores and waterings in the diary.';

  @override
  String get photosEmpty =>
      'No photos in the entries yet. Add photos to entries to build the visual timeline.';

  @override
  String chartWateringSummary(String avg, int ideal) {
    return 'Average: every $avg days · Ideal: every $ideal days';
  }

  @override
  String chartWateringAvgOnly(String avg) {
    return 'Average: every $avg days';
  }

  @override
  String get chartIdealLabel => 'Ideal';

  @override
  String get editSpecies => 'Edit species';

  @override
  String get newSpecies => 'New species';

  @override
  String get addSpecies => 'Add species';

  @override
  String get popularNameLabel => 'Popular name';

  @override
  String get scientificNameLabel => 'Scientific name';

  @override
  String get scientificNameHint => 'E.g.: Nephrolepis exaltata';

  @override
  String get defaultIrrigationFrequencyLabel =>
      'Default watering frequency (days)';

  @override
  String get recommendedSoils => 'Recommended soils';

  @override
  String get speciesFieldLabel => 'Species';

  @override
  String get speciesSearchFieldHint =>
      'Search the official or local database...';

  @override
  String get speciesCustomHelper =>
      'Can\'t find it? Tap + to add your own species.';

  @override
  String get noSpeciesFound => 'No species found';

  @override
  String get noSpeciesRegistered => 'No species registered';

  @override
  String get tapToAddSpecies => 'Tap + to add a new species.';

  @override
  String get deleteSpeciesTitle => 'Delete species?';

  @override
  String get deleteSpeciesBody =>
      'Plants linked to this species will not be affected.';

  @override
  String get floraBrasilBanner =>
      'Using official data from Flora e Funga do Brasil (JBRJ).';

  @override
  String totalSpeciesAvailable(String count) {
    return 'Total species available: $count';
  }

  @override
  String lastUpdate(String date) {
    return 'Last update: $date';
  }

  @override
  String get downloadUpdatedDataset => 'Download updated version (JBRJ)';

  @override
  String get datasetDownloadStarted =>
      'Starting download of the official dataset...';

  @override
  String get datasetUpdated => 'Dataset updated successfully!';

  @override
  String datasetUpdateError(String error) {
    return 'Error updating: $error';
  }

  @override
  String get speciesCareTitle => 'Species care';

  @override
  String get lightLabel => 'Light';

  @override
  String get lightFullSun => 'Full sun';

  @override
  String get lightPartialShade => 'Partial shade';

  @override
  String get lightIndirectBright => 'Bright indirect light';

  @override
  String get lightShade => 'Shade';

  @override
  String get humidityLabel => 'Humidity';

  @override
  String get humidityLow => 'Low';

  @override
  String get humidityMedium => 'Medium';

  @override
  String get humidityHigh => 'High';

  @override
  String get petToxicityLabel => 'Pet toxicity';

  @override
  String get petToxicityUnknown => 'Unknown';

  @override
  String get petToxicityNonToxic => 'Non-toxic';

  @override
  String get petToxicityToxic => 'Toxic';

  @override
  String get toxicToPetsBadge => 'Toxic to pets';

  @override
  String get floweringLabel => 'Flowering months';

  @override
  String floweringIn(String months) {
    return 'Flowers in: $months';
  }

  @override
  String get careNotesLabel => 'Care notes';

  @override
  String get soilSandy => 'Sandy';

  @override
  String get soilClay => 'Clay';

  @override
  String get soilLoamy => 'Loam';

  @override
  String get soilPeaty => 'Peaty';

  @override
  String get soilChalky => 'Chalky';

  @override
  String get soilSilty => 'Silty';

  @override
  String get soilLatosol => 'Latosol';

  @override
  String get soilArgisol => 'Argisol';

  @override
  String get soilTerraRoxa => 'Terra Roxa';

  @override
  String get soilMassape => 'Massapê';

  @override
  String get soilAlluvial => 'Alluvial/Floodplain';

  @override
  String get soilTerraVegetal => 'Topsoil';

  @override
  String get soilPottingMix => 'Potting Mix';

  @override
  String get soilWormCastings => 'Worm Castings';

  @override
  String get soilSucculentMix => 'Succulent Mix';

  @override
  String get soilCoconutFiber => 'Coconut Fiber';

  @override
  String get soilManure => 'Aged Manure';

  @override
  String get soilSandyDesc => 'High drainage, low nutrient retention.';

  @override
  String get soilClayDesc => 'High water retention, tends to compact.';

  @override
  String get soilLoamyDesc => 'Balanced mix of sand, silt and clay.';

  @override
  String get soilPeatyDesc =>
      'Rich in organic matter, retains a lot of moisture.';

  @override
  String get soilChalkyDesc => 'Stony and alkaline, good drainage.';

  @override
  String get soilSiltyDesc => 'Retains moisture well, fertile and soft.';

  @override
  String get soilLatosolDesc =>
      'Rich in iron and aluminum. Very porous and well drained.';

  @override
  String get soilArgisolDesc => 'Clay accumulation at depth. Erosion risk.';

  @override
  String get soilTerraRoxaDesc =>
      'Volcanic origin. Extremely fertile with a reddish color.';

  @override
  String get soilMassapeDesc =>
      'Dark, very clayey and fertile. Typical of NE Brazil.';

  @override
  String get soilAlluvialDesc =>
      'River sediments. Naturally fertile and young.';

  @override
  String get soilTerraVegetalDesc =>
      'Mineral soil mixed with decomposed plant matter.';

  @override
  String get soilPottingMixDesc =>
      'Balanced mix of peat, pine bark and perlite.';

  @override
  String get soilWormCastingsDesc =>
      'Rich in NPK and microorganisms. Great fertilizer.';

  @override
  String get soilSucculentMixDesc =>
      'High drainage. 50% organic and 50% sand or perlite.';

  @override
  String get soilCoconutFiberDesc =>
      'Improves aeration and keeps moisture controlled.';

  @override
  String get soilManureDesc =>
      'Rich organic fertilizer. Always use it decomposed.';

  @override
  String get editSoil => 'Edit soil';

  @override
  String get newSoil => 'New Soil';

  @override
  String get createSoil => 'Create soil';

  @override
  String get selectSoilTitle => 'Select Soil';

  @override
  String get soilTypeLabel => 'Soil type';

  @override
  String get soilNameLabel => 'Soil Name';

  @override
  String get soilNameHint => 'E.g.: Premium Organic Soil';

  @override
  String get compositionLabel => 'Composition (optional)';

  @override
  String get compositionHint =>
      'E.g.: 40% humus, 30% perlite, 30% coconut fiber';

  @override
  String get compositionHelper => 'One line describing the mix.';

  @override
  String get imageSourceLabel => 'Image Source (optional)';

  @override
  String get imageSourceHint => 'E.g.: https://example.com/photo';

  @override
  String imageSource(String source) {
    return 'Source: $source';
  }

  @override
  String get tapToChangeImage => 'Tap to change the image';

  @override
  String get noSoilsFound => 'No soils found';

  @override
  String get noSoilsRegistered => 'No soil types registered';

  @override
  String get tapToAddSoil => 'Tap + to add a soil type.';

  @override
  String get deleteSoilTitle => 'Delete soil?';

  @override
  String get deleteSoilBody =>
      'Plants and species linked to this soil will not be deleted, but the reference to the soil may be lost.';

  @override
  String get editDefensivo => 'Edit pesticide';

  @override
  String get newDefensivo => 'New Pesticide';

  @override
  String get createDefensivo => 'Create pesticide';

  @override
  String get selectDefensivoTitle => 'Select Pesticide';

  @override
  String get defensivoFieldLabel => 'Pesticide';

  @override
  String get defensivoNameLabel => 'Pesticide Name';

  @override
  String get defensivoNameHint => 'E.g.: Bordeaux mixture';

  @override
  String get defensivoCategoryLabel => 'Category';

  @override
  String get defensivoCategoryInsecticide => 'Insecticide';

  @override
  String get defensivoCategoryFungicide => 'Fungicide';

  @override
  String get defensivoCategoryHerbicide => 'Herbicide';

  @override
  String get defensivoCategoryAcaricide => 'Acaricide';

  @override
  String get defensivoCategoryBactericide => 'Bactericide';

  @override
  String get defensivoCategoryNematicide => 'Nematicide';

  @override
  String get defensivoCategoryCustom => 'Other';

  @override
  String get defensivoCustomCategoryLabel => 'Custom category';

  @override
  String get defensivoCustomCategoryHint => 'E.g.: Biological';

  @override
  String get defensivoCompositionLabel =>
      'Composition and application instructions (optional)';

  @override
  String get defensivoCompositionHint =>
      'E.g.: Active ingredient, recommended dose, how to apply';

  @override
  String get defensivoCarenciaLabel =>
      'Withdrawal / re-entry period (optional)';

  @override
  String get defensivoCarenciaHint => 'Days';

  @override
  String get searchDefensivosHint => 'Search pesticides...';

  @override
  String get noDefensivosFound => 'No pesticides found';

  @override
  String get noDefensivosRegistered => 'No pesticides registered';

  @override
  String get tapToAddDefensivo => 'Tap + to add a pesticide.';

  @override
  String get deleteDefensivoTitle => 'Delete pesticide?';

  @override
  String get deleteDefensivoBody =>
      'Records that already used this pesticide will not be affected.';

  @override
  String get editLocation => 'Edit location';

  @override
  String get addLocation => 'Add location';

  @override
  String get locationNameHint => 'E.g.: Living room, Balcony, Bedroom';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String outOfRange(String min, String max) {
    return 'Out of range [$min, $max]';
  }

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get noLocationsFound => 'No locations found';

  @override
  String get noLocationsRegistered => 'No locations registered';

  @override
  String get tapToAddLocation => 'Tap + to add a location.';

  @override
  String get deleteLocationTitle => 'Delete location?';

  @override
  String get deleteLocationBody =>
      'Plants linked to this location will not be deleted, but will be left without a location.';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsSync => 'Sync';

  @override
  String get settingsData => 'Data';

  @override
  String get wateringNotifications => 'Watering Notifications';

  @override
  String get wateringNotificationsSubtitle => 'Enable or disable reminders';

  @override
  String get notificationTime => 'Reminder time';

  @override
  String get notificationTimeSubtitle => 'When watering reminders are shown';

  @override
  String get transparencyAndBlur => 'Transparency and Blur';

  @override
  String get transparencyAndBlurSubtitle => 'Visual effects on cards and menus';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get aboutApp => 'About the App';

  @override
  String get noRemoteWorkspaces =>
      'No remote workspaces yet. Add one to sync this data with a server.';

  @override
  String get addRemoteWorkspace => 'Add remote workspace';

  @override
  String reconnectWorkspace(String name) {
    return 'Reconnect \"$name\"';
  }

  @override
  String get disconnectBody =>
      'This workspace\'s data stays on this device. To sync again, sign in with your account.';

  @override
  String deleteWorkspaceTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteWorkspaceBody =>
      'This workspace\'s data will be erased from this device. This does not affect the account or the data on the server.';

  @override
  String get adminPermissionLost =>
      'You no longer have administrator permission.';

  @override
  String get renameWorkspace => 'Rename workspace';

  @override
  String get localChip => 'Local';

  @override
  String get localNoSync => 'Local — does not sync';

  @override
  String get dataOnlyOnDevice => 'Data only on this device';

  @override
  String get serverAdministration => 'Server administration';

  @override
  String get serverAddressTitle => 'Server address';

  @override
  String get createFirstAccountTitle => 'Create the server\'s first account';

  @override
  String get migrateLocalDataTitle => 'Migrate local data?';

  @override
  String get migrateLocalDataBody =>
      'We found data saved only on this device (local workspace). Do you want to send it to this server now?';

  @override
  String get serverUrlLabel => 'Server URL';

  @override
  String get mustStartWithHttp => 'Must start with http:// or https://';

  @override
  String get firstAccountInfo =>
      'This server has no accounts yet. Create the main account below — it will be used to access it from now on.';

  @override
  String get workspaceNameLabel => 'Name of this workspace';

  @override
  String get workspaceNameHint => 'E.g.: Home greenhouse';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordMinChars => 'At least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get unexpectedConnectError => 'Unexpected error while connecting.';

  @override
  String get unexpectedLoginError => 'Unexpected error while signing in.';

  @override
  String get unexpectedRegisterError =>
      'Unexpected error while creating the account.';

  @override
  String get unexpectedMigrateError =>
      'Unexpected error while migrating the data.';

  @override
  String get promoteToAdminTitle => 'Promote to admin?';

  @override
  String get demoteToMemberTitle => 'Demote to member?';

  @override
  String promoteToAdminBody(String email) {
    return '$email will get full server administration access.';
  }

  @override
  String demoteToMemberBody(String email) {
    return '$email will lose server administration access.';
  }

  @override
  String get promote => 'Promote';

  @override
  String get demote => 'Demote';

  @override
  String get promoteToAdmin => 'Promote to admin';

  @override
  String get demoteToMember => 'Demote to member';

  @override
  String get disableAccountTitle => 'Disable account?';

  @override
  String get enableAccountTitle => 'Re-enable account?';

  @override
  String disableAccountBody(String email) {
    return '$email will no longer be able to sign in. The data is kept.';
  }

  @override
  String enableAccountBody(String email) {
    return '$email will be able to sign in again.';
  }

  @override
  String get disable => 'Disable';

  @override
  String get enable => 'Re-enable';

  @override
  String get disableAccount => 'Disable account';

  @override
  String get enableAccount => 'Re-enable account';

  @override
  String get addUser => 'Add user';

  @override
  String errorLoadingUsers(String error) {
    return 'Error loading users: $error';
  }

  @override
  String errorLoadingStatus(String error) {
    return 'Error loading status: $error';
  }

  @override
  String errorLoadingPermissions(String error) {
    return 'Error loading permissions: $error';
  }

  @override
  String get serverCardTitle => 'Server';

  @override
  String serverUptime(String uptime) {
    return 'Uptime: $uptime';
  }

  @override
  String serverVersion(String version) {
    return 'Version: $version';
  }

  @override
  String serverUsers(String count) {
    return 'Users: $count';
  }

  @override
  String get memberPermissions => 'Member permissions';

  @override
  String get memberExportSubtitle => 'Members can export their own data';

  @override
  String get memberImportSubtitle => 'Members can import data from a backup';

  @override
  String get youChip => 'You';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleMember => 'Member';

  @override
  String get accountDisabled => 'Disabled';

  @override
  String get exportData => 'Export data';

  @override
  String get importData => 'Import data';

  @override
  String get exportDataSubtitle =>
      'Creates a .zip file with the data and photos';

  @override
  String get importDataSubtitle =>
      'Merges an exported backup with the current data';

  @override
  String get checkingPermission => 'Checking permission...';

  @override
  String get permissionCheckFailed =>
      'Could not verify the permission with the server.';

  @override
  String get connectToTransfer => 'Connect to the server to export or import.';

  @override
  String get disabledByAdmin => 'Disabled by the server administrator.';

  @override
  String dataExportedTo(String path) {
    return 'Data exported to $path';
  }

  @override
  String exportError(String error) {
    return 'Error exporting: $error';
  }

  @override
  String get importDataTitle => 'Import data?';

  @override
  String importDataBody(String fileName) {
    return 'The data from \"$fileName\" will be merged into this workspace\'s data. Items edited more recently in the app are kept.';
  }

  @override
  String get importAction => 'Import';

  @override
  String importDone(int applied) {
    String _temp0 = intl.Intl.pluralLogic(
      applied,
      locale: localeName,
      other: 'Import complete: $applied items applied.',
      one: 'Import complete: $applied item applied.',
    );
    return '$_temp0';
  }

  @override
  String importDoneWithSkipped(int applied, int skipped) {
    return 'Import complete: $applied item(s) applied, $skipped skipped for being older.';
  }

  @override
  String get backupCorrupt => 'Invalid backup file.';

  @override
  String get backupUnrecognized =>
      'Unrecognized file: expected a backup .zip or .json.';

  @override
  String get backupNotPolypodium => 'This file is not a Polypodium backup.';

  @override
  String get backupNewerVersion =>
      'Backup created by a newer version of the app. Update Polypodium to import it.';

  @override
  String entryPhotoLabel(String date) {
    return 'Photo from $date';
  }

  @override
  String plantPhotoLabel(String name) {
    return 'Photo of $name';
  }

  @override
  String get removeAction => 'Remove';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String selectPlant(String name) {
    return 'Select $name';
  }

  @override
  String get addSoil => 'Add soil';

  @override
  String get deletePlant => 'Delete plant';

  @override
  String get changeImage => 'Change image';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String chartGrowthSemantics(int count, String first, String last) {
    return 'Growth chart: $count height records, from $first cm to $last cm';
  }

  @override
  String chartHealthSemantics(int count, int score) {
    return 'Health chart: $count scores, most recent $score/5';
  }

  @override
  String chartWateringSemantics(int count, String summary) {
    return 'Watering chart: $count intervals between waterings. $summary';
  }

  @override
  String get repottingHint => 'The new pot and, if it changed, the soil.';

  @override
  String get potDiameterLabel => 'Pot diameter';

  @override
  String get potMaterialLabel => 'Pot material';

  @override
  String get potMaterialPlastic => 'Plastic';

  @override
  String get potMaterialClay => 'Clay';

  @override
  String get potMaterialCeramic => 'Ceramic';

  @override
  String get potMaterialFabric => 'Fabric';

  @override
  String get potMaterialOther => 'Other';

  @override
  String get newSoilLabel => 'New soil';

  @override
  String get newSoilHint => 'Also changes the plant\'s soil.';

  @override
  String get keepCurrentSoil => 'Keep the current soil';

  @override
  String potDiameterSummary(String diameter) {
    return '$diameter cm pot';
  }

  @override
  String get parentPlantLabel => 'Cutting of';

  @override
  String get parentPlantHelper => 'The plant this one was propagated from.';

  @override
  String get cuttingsLabel => 'Cuttings';

  @override
  String get createCutting => 'Create cutting';

  @override
  String cuttingNicknameSuggestion(String name) {
    return '$name (cutting)';
  }

  @override
  String get parentPlantRemoved => 'Removed plant';

  @override
  String carenciaUntil(String date) {
    return 'Pre-harvest interval until $date';
  }

  @override
  String carenciaBadge(String date) {
    return 'Interval until $date';
  }

  @override
  String carenciaDoNotHarvest(String date) {
    return 'Do not harvest until $date';
  }

  @override
  String carenciaDoNotHarvestProducts(String products) {
    return 'Do not harvest — $products';
  }

  @override
  String get entryTypeHarvest => 'Harvest';

  @override
  String get noteHintHarvest => 'Ripeness, quality, where it went...';

  @override
  String get harvestHint => 'How much was harvested.';

  @override
  String get harvestQuantityLabel => 'Quantity';

  @override
  String get harvestUnitLabel => 'Unit';

  @override
  String get harvestUnitG => 'g';

  @override
  String get harvestUnitKg => 'kg';

  @override
  String get harvestUnitUnits => 'units';

  @override
  String get harvestUnitBunches => 'bunches';

  @override
  String harvestAmountG(String quantity) {
    return '$quantity g';
  }

  @override
  String harvestAmountKg(String quantity) {
    return '$quantity kg';
  }

  @override
  String harvestAmountUnits(num count, String quantity) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$quantity units',
      one: '$quantity unit',
    );
    return '$_temp0';
  }

  @override
  String harvestAmountBunches(num count, String quantity) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$quantity bunches',
      one: '$quantity bunch',
    );
    return '$_temp0';
  }

  @override
  String get harvestDuringCarencia =>
      'Harvested during the pre-harvest interval';

  @override
  String get harvestCarenciaDialogTitle =>
      'Harvest during the pre-harvest interval?';

  @override
  String harvestCarenciaDialogBody(String date) {
    return 'This plant is in the pre-harvest interval until $date. Harvesting now may leave pesticide residue.';
  }

  @override
  String harvestCarenciaDialogBulkBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count plants are in the pre-harvest interval. Harvesting them now may leave pesticide residue:',
      one:
          '1 plant is in the pre-harvest interval. Harvesting it now may leave pesticide residue:',
    );
    return '$_temp0';
  }

  @override
  String harvestCarenciaPlantLine(String plant, String date) {
    return '$plant: until $date';
  }

  @override
  String carenciaProductsLine(String products) {
    return 'Products: $products';
  }

  @override
  String get harvestCarenciaQuestion =>
      'Record the harvest anyway? It will be marked as made during the interval.';

  @override
  String get harvestCarenciaConfirm => 'Record anyway';

  @override
  String get harvestTotalsTitle => 'Harvests';

  @override
  String harvestTotalsSummary(String amounts) {
    return 'Harvested in total: $amounts';
  }

  @override
  String get setAsCover => 'Set as cover';

  @override
  String get useLatestAsCover => 'Use the latest photo as cover';

  @override
  String get coverBadge => 'Cover';

  @override
  String coverPhotoLabel(String date) {
    return 'Cover photo from $date';
  }

  @override
  String get photoOptionsHint => 'show photo options';

  @override
  String get coverPhotoUpdated => 'Cover updated';

  @override
  String get photosTitle => 'Photos';

  @override
  String photosCounter(int count, int max) {
    return '$count of $max';
  }

  @override
  String photoNumberLabel(int index, int total) {
    return 'Photo $index of $total';
  }

  @override
  String removePhotoNumber(int index) {
    return 'Remove photo $index';
  }

  @override
  String entryPhotoNumberLabel(int index, int total, String date) {
    return 'Photo $index of $total from $date';
  }

  @override
  String photoPosition(int index, int total) {
    return '$index of $total';
  }

  @override
  String get compareWithFirst => 'Compare with the first photo';

  @override
  String get compareWithOther => 'Compare with another photo';

  @override
  String get pickPhotoToCompare => 'Pick another photo to compare';

  @override
  String get comparisonTitle => 'Before and after';

  @override
  String comparisonBefore(String date) {
    return 'Before · $date';
  }

  @override
  String comparisonAfter(String date) {
    return 'After · $date';
  }

  @override
  String get comparisonSideBySide => 'Side by side';

  @override
  String get comparisonSlider => 'Slider';

  @override
  String get comparisonDivider => 'Divider between the photos';

  @override
  String get labelsGenerate => 'Generate labels';

  @override
  String labelsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labels',
      one: '1 label',
    );
    return '$_temp0';
  }

  @override
  String labelsPages(int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'Fits on $pages A4 pages',
      one: 'Fits on 1 A4 page',
    );
    return '$_temp0';
  }

  @override
  String get labelsSheetLayout => 'Sheet layout';

  @override
  String get labelsPresetA4x24 => '24 per sheet · 70 × 37 mm';

  @override
  String get labelsPresetA4x10 => '10 per sheet · 99 × 57 mm';

  @override
  String get labelsShowLocation => 'Show location';

  @override
  String get labelsShowAcquisitionDate => 'Show acquisition date';

  @override
  String labelsAcquiredOn(String date) {
    return 'Since $date';
  }

  @override
  String get labelsPrint => 'Print';

  @override
  String get labelsSharePdf => 'Share PDF';

  @override
  String get labelsSavePdf => 'Save PDF';

  @override
  String labelsSavedTo(String path) {
    return 'Labels saved to $path';
  }

  @override
  String labelsError(String error) {
    return 'Couldn\'t create the labels: $error';
  }

  @override
  String get labelsPreview => 'Label preview';

  @override
  String get labelScan => 'Scan label';

  @override
  String get labelScanHint => 'Point the camera at a plant label';

  @override
  String get labelScanCameraError => 'Couldn\'t open the camera';

  @override
  String get labelScanInvalid => 'This code isn\'t a Polypodium label';

  @override
  String get labelPlantNotFound => 'Plant not found in this space';

  @override
  String get gardenMembers => 'Garden members';

  @override
  String get gardenPersonal => 'Personal garden';

  @override
  String gardenOf(String email) {
    return '$email\'s garden';
  }

  @override
  String get gardenRoleOwner => 'Owner';

  @override
  String get gardenRoleMember => 'Member';

  @override
  String gardenYou(String email) {
    return '$email (you)';
  }

  @override
  String get gardenYouAreOwner => 'You own this garden';

  @override
  String get gardenYouAreMember => 'You are a member of this garden';

  @override
  String get gardenAddMember => 'Add member';

  @override
  String get gardenAddMemberHint =>
      'The member needs an account on this server, created by its administrator.';

  @override
  String gardenMemberAdded(String email) {
    return '$email added.';
  }

  @override
  String gardenRemoveMemberTooltip(String email) {
    return 'Remove $email';
  }

  @override
  String get gardenRemoveMemberTitle => 'Remove member?';

  @override
  String gardenRemoveMemberBody(String email) {
    return '$email will no longer sync this garden. What they recorded stays in it.';
  }

  @override
  String get gardenRemove => 'Remove';

  @override
  String get gardenLeave => 'Leave garden';

  @override
  String get gardenLeaveBody =>
      'This workspace will stop syncing with the garden. Its data stays on this device.';

  @override
  String get gardenLeft => 'You left the garden.';

  @override
  String get newSharedGarden => 'New shared garden';

  @override
  String get newSharedGardenBody =>
      'Creates an empty garden on this server, in a new workspace. Add members to share it.';

  @override
  String get gardenNameLabel => 'Garden name';

  @override
  String get openGarden => 'Open another garden';

  @override
  String get pickGardenTitle => 'Which garden?';

  @override
  String get pickGardenBody =>
      'This account takes part in shared gardens on this server. Each one syncs in its own workspace.';

  @override
  String get errorGardenAccessDenied =>
      'You are no longer a member of this garden.';

  @override
  String get errorGardensUnsupported =>
      'This server doesn\'t support shared gardens yet. Update it to use them.';

  @override
  String get errorGardenAccountNotFound =>
      'No account with this e-mail on this server.';

  @override
  String get errorGardenAlreadyMember => 'This account is already a member.';

  @override
  String get gardenRetry => 'Try again';

  @override
  String get navHome => 'Home';

  @override
  String get dashboardGoodMorning => 'Good morning';

  @override
  String get dashboardGoodAfternoon => 'Good afternoon';

  @override
  String get dashboardGoodEvening => 'Good evening';

  @override
  String dashboardSummaryDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count care tasks due today',
      one: '1 care task due today',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSummaryClear => 'Everything is up to date 🌿';

  @override
  String get dashboardStatPlants => 'Plants';

  @override
  String get dashboardStatSpecies => 'Species';

  @override
  String get dashboardStatLocations => 'Locations';

  @override
  String dashboardStatEntries(int days) {
    return 'Entries in $days days';
  }

  @override
  String get dashboardTodayTitle => 'Today\'s care';

  @override
  String get dashboardSeeAgenda => 'See agenda';

  @override
  String dashboardMoreTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more tasks',
      one: '+1 more task',
    );
    return '$_temp0';
  }

  @override
  String get dashboardNothingDue => 'Nothing due today.';

  @override
  String dashboardUpcoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks in the coming days',
      one: '1 task in the coming days',
    );
    return '$_temp0';
  }

  @override
  String get dashboardHealthTitle => 'Garden health';

  @override
  String get dashboardHealthy => 'healthy';

  @override
  String dashboardHealthyLabel(int percent) {
    return '$percent% of the plants are healthy';
  }

  @override
  String get dashboardAllHealthy => 'Every plant is doing well.';

  @override
  String get dashboardNeedWater => 'Need water';

  @override
  String get dashboardWithPests => 'With pests';

  @override
  String get dashboardWithChlorosis => 'With chlorosis';

  @override
  String get dashboardPesticideDue => 'Pesticide due';

  @override
  String get dashboardActivityTitle => 'Activity';

  @override
  String dashboardLastDays(int days) {
    return 'Last $days days';
  }

  @override
  String dashboardStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days in a row',
      one: '1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String get dashboardWaterings => 'Waterings';

  @override
  String get dashboardOtherCare => 'Other care';

  @override
  String dashboardActivityChartLabel(int waterings, int care, int days) {
    return '$waterings waterings and $care other entries in the last $days days';
  }

  @override
  String get dashboardNoActivity =>
      'Nothing logged recently. Every care you record shows up here.';

  @override
  String get dashboardYourGarden => 'Your garden';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String get dashboardByLocation => 'By location';

  @override
  String get dashboardNoLocation => 'No location';

  @override
  String get dashboardRecentTitle => 'Recent activity';

  @override
  String get dashboardYesterday => 'Yesterday';

  @override
  String get dashboardEmptyTitle => 'Welcome to your garden';

  @override
  String get dashboardEmptyBody =>
      'Add your first plant to follow its care, health and activity here.';
}
