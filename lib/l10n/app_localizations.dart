import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @navMyPlants.
  ///
  /// In en, this message translates to:
  /// **'My Plants'**
  String get navMyPlants;

  /// No description provided for @navSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get navSpecies;

  /// No description provided for @navLocations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get navLocations;

  /// No description provided for @navSoils.
  ///
  /// In en, this message translates to:
  /// **'Soils'**
  String get navSoils;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @requiredShort.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredShort;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @defaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultValue;

  /// No description provided for @notInformed.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notInformed;

  /// No description provided for @notAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed.'**
  String get notAllowed;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @migrate.
  ///
  /// In en, this message translates to:
  /// **'Migrate'**
  String get migrate;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @positiveNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get positiveNumberRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Date pattern used for dates embedded in persisted history notes
  ///
  /// In en, this message translates to:
  /// **'M/d/yyyy'**
  String get dateFormatPattern;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day} other{{days} days}}'**
  String daysCount(int days);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @syncDownloaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 update synced} other{{count} updates synced}}'**
  String syncDownloaded(int count);

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server — using local data'**
  String get syncOffline;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @allSynced.
  ///
  /// In en, this message translates to:
  /// **'Everything synced'**
  String get allSynced;

  /// No description provided for @pendingEventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} pending event} other{{count} pending events}}'**
  String pendingEventsCount(int count);

  /// No description provided for @autoSync.
  ///
  /// In en, this message translates to:
  /// **'Automatic sync'**
  String get autoSync;

  /// No description provided for @autoSyncOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every 5 minutes (30 in battery saver on Android)'**
  String get autoSyncOnSubtitle;

  /// No description provided for @autoSyncOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disabled — sync manually'**
  String get autoSyncOffSubtitle;

  /// No description provided for @localWorkspaceNoSync.
  ///
  /// In en, this message translates to:
  /// **'Local workspace — does not sync'**
  String get localWorkspaceNoSync;

  /// No description provided for @manageWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Manage workspaces'**
  String get manageWorkspaces;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorSyncReceive.
  ///
  /// In en, this message translates to:
  /// **'Error receiving data from the server'**
  String get errorSyncReceive;

  /// No description provided for @errorSyncSend.
  ///
  /// In en, this message translates to:
  /// **'Error sending data to the server'**
  String get errorSyncSend;

  /// No description provided for @errorNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get errorNotAuthenticated;

  /// No description provided for @errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Server unavailable or invalid URL'**
  String get errorServerUnavailable;

  /// No description provided for @errorAdminForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have administrator permission.'**
  String get errorAdminForbidden;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in'**
  String get errorLoginFailed;

  /// No description provided for @errorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get errorRegisterFailed;

  /// No description provided for @errorServerCommunication.
  ///
  /// In en, this message translates to:
  /// **'Error communicating with the server'**
  String get errorServerCommunication;

  /// No description provided for @errorSpeciesInUse.
  ///
  /// In en, this message translates to:
  /// **'A species with linked plants cannot be deleted.'**
  String get errorSpeciesInUse;

  /// No description provided for @errorSoilInUse.
  ///
  /// In en, this message translates to:
  /// **'A soil with linked plants cannot be deleted.'**
  String get errorSoilInUse;

  /// No description provided for @locationUnsupportedPlatform.
  ///
  /// In en, this message translates to:
  /// **'Geolocation is not supported on Linux desktop.'**
  String get locationUnsupportedPlatform;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'GPS is turned off. Enable it and try again.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Enable it in the device settings.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationFetchError.
  ///
  /// In en, this message translates to:
  /// **'Could not get the location: {error}'**
  String locationFetchError(String error);

  /// No description provided for @galleryPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission to access the gallery was denied'**
  String get galleryPermissionDenied;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery'**
  String get imageSavedToGallery;

  /// No description provided for @imageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving image: {error}'**
  String imageSaveError(String error);

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Error sharing: {error}'**
  String shareError(String error);

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get saveToGallery;

  /// No description provided for @irrigationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get irrigationChannelName;

  /// No description provided for @irrigationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Watering reminders for your plants'**
  String get irrigationChannelDescription;

  /// No description provided for @irrigationNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to water! 🌿'**
  String get irrigationNotificationTitle;

  /// No description provided for @irrigationNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{nickname} needs to be watered today.'**
  String irrigationNotificationBody(String nickname);

  /// No description provided for @historyPlantAdded.
  ///
  /// In en, this message translates to:
  /// **'Plant added to the system:'**
  String get historyPlantAdded;

  /// No description provided for @historyFieldNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get historyFieldNickname;

  /// No description provided for @historyFieldSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get historyFieldSpecies;

  /// No description provided for @historyFieldSoil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get historyFieldSoil;

  /// No description provided for @historyFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get historyFieldLocation;

  /// No description provided for @historyFieldAcquisitionDate.
  ///
  /// In en, this message translates to:
  /// **'Acquisition date'**
  String get historyFieldAcquisitionDate;

  /// No description provided for @historyFieldWateringFrequency.
  ///
  /// In en, this message translates to:
  /// **'Watering frequency'**
  String get historyFieldWateringFrequency;

  /// No description provided for @historyAcquiredOn.
  ///
  /// In en, this message translates to:
  /// **'Acquired on'**
  String get historyAcquiredOn;

  /// No description provided for @historyCustomWatering.
  ///
  /// In en, this message translates to:
  /// **'Custom watering: {days}'**
  String historyCustomWatering(String days);

  /// No description provided for @historyUpdatedHeader.
  ///
  /// In en, this message translates to:
  /// **'Updated information:'**
  String get historyUpdatedHeader;

  /// No description provided for @searchPlantsHint.
  ///
  /// In en, this message translates to:
  /// **'Search plants...'**
  String get searchPlantsHint;

  /// No description provided for @searchSpeciesHint.
  ///
  /// In en, this message translates to:
  /// **'Search species...'**
  String get searchSpeciesHint;

  /// No description provided for @searchSoilsHint.
  ///
  /// In en, this message translates to:
  /// **'Search soils...'**
  String get searchSoilsHint;

  /// No description provided for @searchLocationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search locations...'**
  String get searchLocationsHint;

  /// No description provided for @sortWateringNeeds.
  ///
  /// In en, this message translates to:
  /// **'Watering needs'**
  String get sortWateringNeeds;

  /// No description provided for @sortNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortNameAZ;

  /// No description provided for @sortNameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get sortNameZA;

  /// No description provided for @sortLastWatered.
  ///
  /// In en, this message translates to:
  /// **'Last watered'**
  String get sortLastWatered;

  /// No description provided for @sortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get sortDateAdded;

  /// No description provided for @sortPopularNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Popular Name (A-Z)'**
  String get sortPopularNameAZ;

  /// No description provided for @sortPopularNameZA.
  ///
  /// In en, this message translates to:
  /// **'Popular Name (Z-A)'**
  String get sortPopularNameZA;

  /// No description provided for @sortScientificNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Scientific Name (A-Z)'**
  String get sortScientificNameAZ;

  /// No description provided for @sortScientificNameZA.
  ///
  /// In en, this message translates to:
  /// **'Scientific Name (Z-A)'**
  String get sortScientificNameZA;

  /// No description provided for @sortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewestFirst;

  /// No description provided for @sortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldestFirst;

  /// No description provided for @sortByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get sortByType;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @errorLoadingPlants.
  ///
  /// In en, this message translates to:
  /// **'Error loading plants: {error}'**
  String errorLoadingPlants(String error);

  /// No description provided for @noPlantsFound.
  ///
  /// In en, this message translates to:
  /// **'No plants found'**
  String get noPlantsFound;

  /// No description provided for @noPlantsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No plants registered'**
  String get noPlantsRegistered;

  /// No description provided for @tapToAddFirstPlant.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first plant.'**
  String get tapToAddFirstPlant;

  /// No description provided for @deletePlantsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Delete {count} plant?} other{Delete {count} plants?}}'**
  String deletePlantsTitle(int count);

  /// No description provided for @deletePlantsBody.
  ///
  /// In en, this message translates to:
  /// **'All records of these plants will be removed.'**
  String get deletePlantsBody;

  /// No description provided for @deletePlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete plant?'**
  String get deletePlantTitle;

  /// No description provided for @deletePlantBody.
  ///
  /// In en, this message translates to:
  /// **'All records of this plant will be removed.'**
  String get deletePlantBody;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get cancelSelection;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get deleteSelected;

  /// No description provided for @editPlant.
  ///
  /// In en, this message translates to:
  /// **'Edit plant'**
  String get editPlant;

  /// No description provided for @newPlant.
  ///
  /// In en, this message translates to:
  /// **'New plant'**
  String get newPlant;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlant;

  /// No description provided for @sectionIdentification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get sectionIdentification;

  /// No description provided for @sectionCare.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get sectionCare;

  /// No description provided for @sectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get sectionDetails;

  /// No description provided for @sectionInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get sectionInformation;

  /// No description provided for @sectionCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get sectionCoordinates;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Living room fern'**
  String get nicknameHint;

  /// No description provided for @nicknameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a nickname'**
  String get nicknameRequired;

  /// No description provided for @speciesRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a species'**
  String get speciesRequired;

  /// No description provided for @selectSpeciesFromList.
  ///
  /// In en, this message translates to:
  /// **'Select a species from the list'**
  String get selectSpeciesFromList;

  /// No description provided for @selectSoilType.
  ///
  /// In en, this message translates to:
  /// **'Select a soil type'**
  String get selectSoilType;

  /// No description provided for @newSoilType.
  ///
  /// In en, this message translates to:
  /// **'New soil type'**
  String get newSoilType;

  /// No description provided for @newLocation.
  ///
  /// In en, this message translates to:
  /// **'New location'**
  String get newLocation;

  /// No description provided for @irrigationFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Watering frequency (days)'**
  String get irrigationFrequencyLabel;

  /// No description provided for @irrigationFrequencyShort.
  ///
  /// In en, this message translates to:
  /// **'Watering frequency'**
  String get irrigationFrequencyShort;

  /// No description provided for @irrigationFrequencyHelper.
  ///
  /// In en, this message translates to:
  /// **'If set, the app will send watering reminders.'**
  String get irrigationFrequencyHelper;

  /// No description provided for @recommendedSuffix.
  ///
  /// In en, this message translates to:
  /// **'(recommended)'**
  String get recommendedSuffix;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @acquisitionDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Acquisition date'**
  String get acquisitionDateLabel;

  /// No description provided for @acquiredOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Acquired on'**
  String get acquiredOnLabel;

  /// No description provided for @plantNotFound.
  ///
  /// In en, this message translates to:
  /// **'Plant not found'**
  String get plantNotFound;

  /// No description provided for @soilLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get soilLabel;

  /// No description provided for @needsWater.
  ///
  /// In en, this message translates to:
  /// **'Needs water!'**
  String get needsWater;

  /// No description provided for @wateringUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Watering up to date'**
  String get wateringUpToDate;

  /// No description provided for @lastWateringNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Last watering not recorded'**
  String get lastWateringNotRecorded;

  /// No description provided for @daysOverdue.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day overdue} other{{days} days overdue}}'**
  String daysOverdue(int days);

  /// No description provided for @nextWateringInDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{Next watering in {days} day} other{Next watering in {days} days}}'**
  String nextWateringInDays(int days);

  /// No description provided for @wateredNow.
  ///
  /// In en, this message translates to:
  /// **'Watered now'**
  String get wateredNow;

  /// No description provided for @irrigationRecorded.
  ///
  /// In en, this message translates to:
  /// **'Watering recorded!'**
  String get irrigationRecorded;

  /// No description provided for @irrigationRecordError.
  ///
  /// In en, this message translates to:
  /// **'Error recording watering: {error}'**
  String irrigationRecordError(String error);

  /// No description provided for @entriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entriesTitle;

  /// No description provided for @entryTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry types'**
  String get entryTypesTitle;

  /// No description provided for @filterTypes.
  ///
  /// In en, this message translates to:
  /// **'Filter types'**
  String get filterTypes;

  /// No description provided for @noEntriesFound.
  ///
  /// In en, this message translates to:
  /// **'No entries found'**
  String get noEntriesFound;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntryTitle;

  /// No description provided for @severityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityMild;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @severityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get severityActive;

  /// No description provided for @pestBadge.
  ///
  /// In en, this message translates to:
  /// **'Pest'**
  String get pestBadge;

  /// No description provided for @entryTypeIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get entryTypeIrrigation;

  /// No description provided for @entryTypeFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizing'**
  String get entryTypeFertilizer;

  /// No description provided for @entryTypePruning.
  ///
  /// In en, this message translates to:
  /// **'Pruning'**
  String get entryTypePruning;

  /// No description provided for @entryTypeObservation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get entryTypeObservation;

  /// No description provided for @entryTypeHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get entryTypeHeight;

  /// No description provided for @entryTypeChlorosis.
  ///
  /// In en, this message translates to:
  /// **'Chlorosis'**
  String get entryTypeChlorosis;

  /// No description provided for @entryTypePest.
  ///
  /// In en, this message translates to:
  /// **'Pests'**
  String get entryTypePest;

  /// No description provided for @entryTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get entryTypeOther;

  /// No description provided for @entryTypeHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get entryTypeHistory;

  /// No description provided for @newEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntryTitle;

  /// No description provided for @entryTypeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry type'**
  String get entryTypeCardTitle;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @noteHintIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Anything in the water? Any observations?'**
  String get noteHintIrrigation;

  /// No description provided for @noteHintFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Frequency, application method...'**
  String get noteHintFertilizer;

  /// No description provided for @noteHintPruning.
  ///
  /// In en, this message translates to:
  /// **'How was the plant before pruning?'**
  String get noteHintPruning;

  /// No description provided for @noteHintObservation.
  ///
  /// In en, this message translates to:
  /// **'How is the plant today?'**
  String get noteHintObservation;

  /// No description provided for @noteHintHeight.
  ///
  /// In en, this message translates to:
  /// **'Any observations about growth?'**
  String get noteHintHeight;

  /// No description provided for @noteHintChlorosis.
  ///
  /// In en, this message translates to:
  /// **'Which leaves are affected?'**
  String get noteHintChlorosis;

  /// No description provided for @noteHintPest.
  ///
  /// In en, this message translates to:
  /// **'Where was it found? Any treatment?'**
  String get noteHintPest;

  /// No description provided for @noteHintDefault.
  ///
  /// In en, this message translates to:
  /// **'Optional notes...'**
  String get noteHintDefault;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoTitle;

  /// No description provided for @saveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get saveEntry;

  /// No description provided for @pruningFormation.
  ///
  /// In en, this message translates to:
  /// **'Formation'**
  String get pruningFormation;

  /// No description provided for @pruningCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get pruningCleaning;

  /// No description provided for @pruningRejuvenation.
  ///
  /// In en, this message translates to:
  /// **'Rejuvenation'**
  String get pruningRejuvenation;

  /// No description provided for @pruningHarvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get pruningHarvest;

  /// No description provided for @pruningReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get pruningReasonHint;

  /// No description provided for @irrigationScarce.
  ///
  /// In en, this message translates to:
  /// **'Scarce'**
  String get irrigationScarce;

  /// No description provided for @irrigationScarceDesc.
  ///
  /// In en, this message translates to:
  /// **'Soil slightly moist'**
  String get irrigationScarceDesc;

  /// No description provided for @irrigationModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get irrigationModerate;

  /// No description provided for @irrigationModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Normal watering, soil well moistened'**
  String get irrigationModerateDesc;

  /// No description provided for @irrigationIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get irrigationIntense;

  /// No description provided for @irrigationIntenseDesc.
  ///
  /// In en, this message translates to:
  /// **'Soaked soil / long duration'**
  String get irrigationIntenseDesc;

  /// No description provided for @irrigationIntensityHint.
  ///
  /// In en, this message translates to:
  /// **'Watering intensity (optional)'**
  String get irrigationIntensityHint;

  /// No description provided for @fertilizerProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Product(s) used — optional'**
  String get fertilizerProductsHint;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @productHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Growth fertilizer'**
  String get productHint;

  /// No description provided for @doseLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get doseLabel;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @healthScoreHint.
  ///
  /// In en, this message translates to:
  /// **'Plant health score (optional)'**
  String get healthScoreHint;

  /// No description provided for @healthCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get healthCritical;

  /// No description provided for @healthBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get healthBad;

  /// No description provided for @healthRegular.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get healthRegular;

  /// No description provided for @healthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthGood;

  /// No description provided for @healthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get healthExcellent;

  /// No description provided for @healthSummary.
  ///
  /// In en, this message translates to:
  /// **'Health {score}/5'**
  String healthSummary(int score);

  /// No description provided for @heightSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant height'**
  String get heightSectionTitle;

  /// No description provided for @heightCmLabel.
  ///
  /// In en, this message translates to:
  /// **'Height in cm'**
  String get heightCmLabel;

  /// No description provided for @heightHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: 32.5'**
  String get heightHint;

  /// No description provided for @heightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid height in cm'**
  String get heightInvalid;

  /// No description provided for @heightMeasureHint.
  ///
  /// In en, this message translates to:
  /// **'Measure from soil level to the tallest leaf.'**
  String get heightMeasureHint;

  /// No description provided for @severitySelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select the severity *'**
  String get severitySelectHint;

  /// No description provided for @chlorosisCured.
  ///
  /// In en, this message translates to:
  /// **'Cured'**
  String get chlorosisCured;

  /// No description provided for @chlorosisCuredDesc.
  ///
  /// In en, this message translates to:
  /// **'Plant with no active chlorosis'**
  String get chlorosisCuredDesc;

  /// No description provided for @chlorosisMildDesc.
  ///
  /// In en, this message translates to:
  /// **'Few yellowing leaves'**
  String get chlorosisMildDesc;

  /// No description provided for @chlorosisModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Several leaves affected'**
  String get chlorosisModerateDesc;

  /// No description provided for @chlorosisSevereDesc.
  ///
  /// In en, this message translates to:
  /// **'Most leaves affected'**
  String get chlorosisSevereDesc;

  /// No description provided for @pestTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pest type'**
  String get pestTypeLabel;

  /// No description provided for @pestTypeHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Mealybug, Aphid, Mite...'**
  String get pestTypeHint;

  /// No description provided for @pestTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the pest type'**
  String get pestTypeRequired;

  /// No description provided for @pestSeverityHint.
  ///
  /// In en, this message translates to:
  /// **'Infestation severity *'**
  String get pestSeverityHint;

  /// No description provided for @pestEradicated.
  ///
  /// In en, this message translates to:
  /// **'Eradicated'**
  String get pestEradicated;

  /// No description provided for @pestEradicatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Plant free of pests'**
  String get pestEradicatedDesc;

  /// No description provided for @pestMildDesc.
  ///
  /// In en, this message translates to:
  /// **'Few individuals / small area'**
  String get pestMildDesc;

  /// No description provided for @pestModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Several areas affected'**
  String get pestModerateDesc;

  /// No description provided for @pestSevereDesc.
  ///
  /// In en, this message translates to:
  /// **'Widespread infestation'**
  String get pestSevereDesc;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} product} other{{count} products}}'**
  String productsCount(int count);

  /// No description provided for @editSpecies.
  ///
  /// In en, this message translates to:
  /// **'Edit species'**
  String get editSpecies;

  /// No description provided for @newSpecies.
  ///
  /// In en, this message translates to:
  /// **'New species'**
  String get newSpecies;

  /// No description provided for @addSpecies.
  ///
  /// In en, this message translates to:
  /// **'Add species'**
  String get addSpecies;

  /// No description provided for @popularNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Popular name'**
  String get popularNameLabel;

  /// No description provided for @scientificNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Scientific name'**
  String get scientificNameLabel;

  /// No description provided for @scientificNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Nephrolepis exaltata'**
  String get scientificNameHint;

  /// No description provided for @defaultIrrigationFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Default watering frequency (days)'**
  String get defaultIrrigationFrequencyLabel;

  /// No description provided for @recommendedSoils.
  ///
  /// In en, this message translates to:
  /// **'Recommended soils'**
  String get recommendedSoils;

  /// No description provided for @speciesFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get speciesFieldLabel;

  /// No description provided for @speciesSearchFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Search the official or local database...'**
  String get speciesSearchFieldHint;

  /// No description provided for @noSpeciesFound.
  ///
  /// In en, this message translates to:
  /// **'No species found'**
  String get noSpeciesFound;

  /// No description provided for @noSpeciesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No species registered'**
  String get noSpeciesRegistered;

  /// No description provided for @tapToAddSpecies.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new species.'**
  String get tapToAddSpecies;

  /// No description provided for @deleteSpeciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete species?'**
  String get deleteSpeciesTitle;

  /// No description provided for @deleteSpeciesBody.
  ///
  /// In en, this message translates to:
  /// **'Plants linked to this species will not be affected.'**
  String get deleteSpeciesBody;

  /// No description provided for @floraBrasilBanner.
  ///
  /// In en, this message translates to:
  /// **'Using official data from Flora e Funga do Brasil (JBRJ).'**
  String get floraBrasilBanner;

  /// No description provided for @totalSpeciesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Total species available: {count}'**
  String totalSpeciesAvailable(String count);

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update: {date}'**
  String lastUpdate(String date);

  /// No description provided for @downloadUpdatedDataset.
  ///
  /// In en, this message translates to:
  /// **'Download updated version (JBRJ)'**
  String get downloadUpdatedDataset;

  /// No description provided for @datasetDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Starting download of the official dataset...'**
  String get datasetDownloadStarted;

  /// No description provided for @datasetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Dataset updated successfully!'**
  String get datasetUpdated;

  /// No description provided for @datasetUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating: {error}'**
  String datasetUpdateError(String error);

  /// No description provided for @soilSandy.
  ///
  /// In en, this message translates to:
  /// **'Sandy'**
  String get soilSandy;

  /// No description provided for @soilClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get soilClay;

  /// No description provided for @soilLoamy.
  ///
  /// In en, this message translates to:
  /// **'Loam'**
  String get soilLoamy;

  /// No description provided for @soilPeaty.
  ///
  /// In en, this message translates to:
  /// **'Peaty'**
  String get soilPeaty;

  /// No description provided for @soilChalky.
  ///
  /// In en, this message translates to:
  /// **'Chalky'**
  String get soilChalky;

  /// No description provided for @soilSilty.
  ///
  /// In en, this message translates to:
  /// **'Silty'**
  String get soilSilty;

  /// No description provided for @soilLatosol.
  ///
  /// In en, this message translates to:
  /// **'Latosol'**
  String get soilLatosol;

  /// No description provided for @soilArgisol.
  ///
  /// In en, this message translates to:
  /// **'Argisol'**
  String get soilArgisol;

  /// No description provided for @soilTerraRoxa.
  ///
  /// In en, this message translates to:
  /// **'Terra Roxa'**
  String get soilTerraRoxa;

  /// No description provided for @soilMassape.
  ///
  /// In en, this message translates to:
  /// **'Massapê'**
  String get soilMassape;

  /// No description provided for @soilAlluvial.
  ///
  /// In en, this message translates to:
  /// **'Alluvial/Floodplain'**
  String get soilAlluvial;

  /// No description provided for @soilTerraVegetal.
  ///
  /// In en, this message translates to:
  /// **'Topsoil'**
  String get soilTerraVegetal;

  /// No description provided for @soilPottingMix.
  ///
  /// In en, this message translates to:
  /// **'Potting Mix'**
  String get soilPottingMix;

  /// No description provided for @soilWormCastings.
  ///
  /// In en, this message translates to:
  /// **'Worm Castings'**
  String get soilWormCastings;

  /// No description provided for @soilSucculentMix.
  ///
  /// In en, this message translates to:
  /// **'Succulent Mix'**
  String get soilSucculentMix;

  /// No description provided for @soilCoconutFiber.
  ///
  /// In en, this message translates to:
  /// **'Coconut Fiber'**
  String get soilCoconutFiber;

  /// No description provided for @soilManure.
  ///
  /// In en, this message translates to:
  /// **'Aged Manure'**
  String get soilManure;

  /// No description provided for @soilSandyDesc.
  ///
  /// In en, this message translates to:
  /// **'High drainage, low nutrient retention.'**
  String get soilSandyDesc;

  /// No description provided for @soilClayDesc.
  ///
  /// In en, this message translates to:
  /// **'High water retention, tends to compact.'**
  String get soilClayDesc;

  /// No description provided for @soilLoamyDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced mix of sand, silt and clay.'**
  String get soilLoamyDesc;

  /// No description provided for @soilPeatyDesc.
  ///
  /// In en, this message translates to:
  /// **'Rich in organic matter, retains a lot of moisture.'**
  String get soilPeatyDesc;

  /// No description provided for @soilChalkyDesc.
  ///
  /// In en, this message translates to:
  /// **'Stony and alkaline, good drainage.'**
  String get soilChalkyDesc;

  /// No description provided for @soilSiltyDesc.
  ///
  /// In en, this message translates to:
  /// **'Retains moisture well, fertile and soft.'**
  String get soilSiltyDesc;

  /// No description provided for @soilLatosolDesc.
  ///
  /// In en, this message translates to:
  /// **'Rich in iron and aluminum. Very porous and well drained.'**
  String get soilLatosolDesc;

  /// No description provided for @soilArgisolDesc.
  ///
  /// In en, this message translates to:
  /// **'Clay accumulation at depth. Erosion risk.'**
  String get soilArgisolDesc;

  /// No description provided for @soilTerraRoxaDesc.
  ///
  /// In en, this message translates to:
  /// **'Volcanic origin. Extremely fertile with a reddish color.'**
  String get soilTerraRoxaDesc;

  /// No description provided for @soilMassapeDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark, very clayey and fertile. Typical of NE Brazil.'**
  String get soilMassapeDesc;

  /// No description provided for @soilAlluvialDesc.
  ///
  /// In en, this message translates to:
  /// **'River sediments. Naturally fertile and young.'**
  String get soilAlluvialDesc;

  /// No description provided for @soilTerraVegetalDesc.
  ///
  /// In en, this message translates to:
  /// **'Mineral soil mixed with decomposed plant matter.'**
  String get soilTerraVegetalDesc;

  /// No description provided for @soilPottingMixDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced mix of peat, pine bark and perlite.'**
  String get soilPottingMixDesc;

  /// No description provided for @soilWormCastingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Rich in NPK and microorganisms. Great fertilizer.'**
  String get soilWormCastingsDesc;

  /// No description provided for @soilSucculentMixDesc.
  ///
  /// In en, this message translates to:
  /// **'High drainage. 50% organic and 50% sand or perlite.'**
  String get soilSucculentMixDesc;

  /// No description provided for @soilCoconutFiberDesc.
  ///
  /// In en, this message translates to:
  /// **'Improves aeration and keeps moisture controlled.'**
  String get soilCoconutFiberDesc;

  /// No description provided for @soilManureDesc.
  ///
  /// In en, this message translates to:
  /// **'Rich organic fertilizer. Always use it decomposed.'**
  String get soilManureDesc;

  /// No description provided for @editSoil.
  ///
  /// In en, this message translates to:
  /// **'Edit soil'**
  String get editSoil;

  /// No description provided for @newSoil.
  ///
  /// In en, this message translates to:
  /// **'New Soil'**
  String get newSoil;

  /// No description provided for @createSoil.
  ///
  /// In en, this message translates to:
  /// **'Create soil'**
  String get createSoil;

  /// No description provided for @selectSoilTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Soil'**
  String get selectSoilTitle;

  /// No description provided for @soilTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil type'**
  String get soilTypeLabel;

  /// No description provided for @soilNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil Name'**
  String get soilNameLabel;

  /// No description provided for @soilNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Premium Organic Soil'**
  String get soilNameHint;

  /// No description provided for @compositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Composition (optional)'**
  String get compositionLabel;

  /// No description provided for @compositionHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: 40% humus, 30% perlite, 30% coconut fiber'**
  String get compositionHint;

  /// No description provided for @compositionHelper.
  ///
  /// In en, this message translates to:
  /// **'One line describing the mix.'**
  String get compositionHelper;

  /// No description provided for @imageSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Image Source (optional)'**
  String get imageSourceLabel;

  /// No description provided for @imageSourceHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: https://example.com/photo'**
  String get imageSourceHint;

  /// No description provided for @imageSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String imageSource(String source);

  /// No description provided for @tapToChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to change the image'**
  String get tapToChangeImage;

  /// No description provided for @noSoilsFound.
  ///
  /// In en, this message translates to:
  /// **'No soils found'**
  String get noSoilsFound;

  /// No description provided for @noSoilsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No soil types registered'**
  String get noSoilsRegistered;

  /// No description provided for @tapToAddSoil.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a soil type.'**
  String get tapToAddSoil;

  /// No description provided for @deleteSoilTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete soil?'**
  String get deleteSoilTitle;

  /// No description provided for @deleteSoilBody.
  ///
  /// In en, this message translates to:
  /// **'Plants and species linked to this soil will not be deleted, but the reference to the soil may be lost.'**
  String get deleteSoilBody;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get editLocation;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get addLocation;

  /// No description provided for @locationNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Living room, Balcony, Bedroom'**
  String get locationNameHint;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @outOfRange.
  ///
  /// In en, this message translates to:
  /// **'Out of range [{min}, {max}]'**
  String outOfRange(String min, String max);

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @noLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationsFound;

  /// No description provided for @noLocationsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No locations registered'**
  String get noLocationsRegistered;

  /// No description provided for @tapToAddLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a location.'**
  String get tapToAddLocation;

  /// No description provided for @deleteLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete location?'**
  String get deleteLocationTitle;

  /// No description provided for @deleteLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Plants linked to this location will not be deleted, but will be left without a location.'**
  String get deleteLocationBody;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSync;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @wateringNotifications.
  ///
  /// In en, this message translates to:
  /// **'Watering Notifications'**
  String get wateringNotifications;

  /// No description provided for @wateringNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable reminders'**
  String get wateringNotificationsSubtitle;

  /// No description provided for @transparencyAndBlur.
  ///
  /// In en, this message translates to:
  /// **'Transparency and Blur'**
  String get transparencyAndBlur;

  /// No description provided for @transparencyAndBlurSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visual effects on cards and menus'**
  String get transparencyAndBlurSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @noRemoteWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'No remote workspaces yet. Add one to sync this data with a server.'**
  String get noRemoteWorkspaces;

  /// No description provided for @addRemoteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Add remote workspace'**
  String get addRemoteWorkspace;

  /// No description provided for @reconnectWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Reconnect \"{name}\"'**
  String reconnectWorkspace(String name);

  /// No description provided for @disconnectBody.
  ///
  /// In en, this message translates to:
  /// **'This workspace\'s data stays on this device. To sync again, sign in with your account.'**
  String get disconnectBody;

  /// No description provided for @deleteWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteWorkspaceTitle(String name);

  /// No description provided for @deleteWorkspaceBody.
  ///
  /// In en, this message translates to:
  /// **'This workspace\'s data will be erased from this device. This does not affect the account or the data on the server.'**
  String get deleteWorkspaceBody;

  /// No description provided for @adminPermissionLost.
  ///
  /// In en, this message translates to:
  /// **'You no longer have administrator permission.'**
  String get adminPermissionLost;

  /// No description provided for @renameWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Rename workspace'**
  String get renameWorkspace;

  /// No description provided for @localChip.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get localChip;

  /// No description provided for @localNoSync.
  ///
  /// In en, this message translates to:
  /// **'Local — does not sync'**
  String get localNoSync;

  /// No description provided for @dataOnlyOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Data only on this device'**
  String get dataOnlyOnDevice;

  /// No description provided for @serverAdministration.
  ///
  /// In en, this message translates to:
  /// **'Server administration'**
  String get serverAdministration;

  /// No description provided for @serverAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddressTitle;

  /// No description provided for @createFirstAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create the server\'s first account'**
  String get createFirstAccountTitle;

  /// No description provided for @migrateLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Migrate local data?'**
  String get migrateLocalDataTitle;

  /// No description provided for @migrateLocalDataBody.
  ///
  /// In en, this message translates to:
  /// **'We found data saved only on this device (local workspace). Do you want to send it to this server now?'**
  String get migrateLocalDataBody;

  /// No description provided for @serverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrlLabel;

  /// No description provided for @mustStartWithHttp.
  ///
  /// In en, this message translates to:
  /// **'Must start with http:// or https://'**
  String get mustStartWithHttp;

  /// No description provided for @firstAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'This server has no accounts yet. Create the main account below — it will be used to access it from now on.'**
  String get firstAccountInfo;

  /// No description provided for @workspaceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name of this workspace'**
  String get workspaceNameLabel;

  /// No description provided for @workspaceNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Home greenhouse'**
  String get workspaceNameHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordMinChars;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @unexpectedConnectError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error while connecting.'**
  String get unexpectedConnectError;

  /// No description provided for @unexpectedLoginError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error while signing in.'**
  String get unexpectedLoginError;

  /// No description provided for @unexpectedRegisterError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error while creating the account.'**
  String get unexpectedRegisterError;

  /// No description provided for @unexpectedMigrateError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error while migrating the data.'**
  String get unexpectedMigrateError;

  /// No description provided for @promoteToAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote to admin?'**
  String get promoteToAdminTitle;

  /// No description provided for @demoteToMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Demote to member?'**
  String get demoteToMemberTitle;

  /// No description provided for @promoteToAdminBody.
  ///
  /// In en, this message translates to:
  /// **'{email} will get full server administration access.'**
  String promoteToAdminBody(String email);

  /// No description provided for @demoteToMemberBody.
  ///
  /// In en, this message translates to:
  /// **'{email} will lose server administration access.'**
  String demoteToMemberBody(String email);

  /// No description provided for @promote.
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promote;

  /// No description provided for @demote.
  ///
  /// In en, this message translates to:
  /// **'Demote'**
  String get demote;

  /// No description provided for @promoteToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Promote to admin'**
  String get promoteToAdmin;

  /// No description provided for @demoteToMember.
  ///
  /// In en, this message translates to:
  /// **'Demote to member'**
  String get demoteToMember;

  /// No description provided for @disableAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable account?'**
  String get disableAccountTitle;

  /// No description provided for @enableAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-enable account?'**
  String get enableAccountTitle;

  /// No description provided for @disableAccountBody.
  ///
  /// In en, this message translates to:
  /// **'{email} will no longer be able to sign in. The data is kept.'**
  String disableAccountBody(String email);

  /// No description provided for @enableAccountBody.
  ///
  /// In en, this message translates to:
  /// **'{email} will be able to sign in again.'**
  String enableAccountBody(String email);

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Re-enable'**
  String get enable;

  /// No description provided for @disableAccount.
  ///
  /// In en, this message translates to:
  /// **'Disable account'**
  String get disableAccount;

  /// No description provided for @enableAccount.
  ///
  /// In en, this message translates to:
  /// **'Re-enable account'**
  String get enableAccount;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUser;

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users: {error}'**
  String errorLoadingUsers(String error);

  /// No description provided for @errorLoadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Error loading status: {error}'**
  String errorLoadingStatus(String error);

  /// No description provided for @errorLoadingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Error loading permissions: {error}'**
  String errorLoadingPermissions(String error);

  /// No description provided for @serverCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverCardTitle;

  /// No description provided for @serverUptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime: {uptime}'**
  String serverUptime(String uptime);

  /// No description provided for @serverVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String serverVersion(String version);

  /// No description provided for @serverUsers.
  ///
  /// In en, this message translates to:
  /// **'Users: {count}'**
  String serverUsers(String count);

  /// No description provided for @memberPermissions.
  ///
  /// In en, this message translates to:
  /// **'Member permissions'**
  String get memberPermissions;

  /// No description provided for @memberExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Members can export their own data'**
  String get memberExportSubtitle;

  /// No description provided for @memberImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Members can import data from a backup'**
  String get memberImportSubtitle;

  /// No description provided for @youChip.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youChip;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get accountDisabled;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Creates a .zip file with the data and photos'**
  String get exportDataSubtitle;

  /// No description provided for @importDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Merges an exported backup with the current data'**
  String get importDataSubtitle;

  /// No description provided for @checkingPermission.
  ///
  /// In en, this message translates to:
  /// **'Checking permission...'**
  String get checkingPermission;

  /// No description provided for @permissionCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the permission with the server.'**
  String get permissionCheckFailed;

  /// No description provided for @connectToTransfer.
  ///
  /// In en, this message translates to:
  /// **'Connect to the server to export or import.'**
  String get connectToTransfer;

  /// No description provided for @disabledByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Disabled by the server administrator.'**
  String get disabledByAdmin;

  /// No description provided for @dataExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Data exported to {path}'**
  String dataExportedTo(String path);

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting: {error}'**
  String exportError(String error);

  /// No description provided for @importDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Import data?'**
  String get importDataTitle;

  /// No description provided for @importDataBody.
  ///
  /// In en, this message translates to:
  /// **'The data from \"{fileName}\" will be merged into this workspace\'s data. Items edited more recently in the app are kept.'**
  String importDataBody(String fileName);

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{applied, plural, one{Import complete: {applied} item applied.} other{Import complete: {applied} items applied.}}'**
  String importDone(int applied);

  /// No description provided for @importDoneWithSkipped.
  ///
  /// In en, this message translates to:
  /// **'Import complete: {applied} item(s) applied, {skipped} skipped for being older.'**
  String importDoneWithSkipped(int applied, int skipped);

  /// No description provided for @backupCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file.'**
  String get backupCorrupt;

  /// No description provided for @backupUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized file: expected a backup .zip or .json.'**
  String get backupUnrecognized;

  /// No description provided for @backupNotPolypodium.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Polypodium backup.'**
  String get backupNotPolypodium;

  /// No description provided for @backupNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'Backup created by a newer version of the app. Update Polypodium to import it.'**
  String get backupNewerVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
