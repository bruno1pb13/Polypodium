import '../domain_exceptions.dart';
import '../location/location_service.dart';
import '../sync/sync_exceptions.dart';
import '../../l10n/app_localizations.dart';

/// Maps typed exceptions thrown by services/clients to localized,
/// user-facing messages. Falls back to the error's own text for
/// anything unknown.
String localizedErrorMessage(Object error, AppLocalizations l10n) {
  return switch (error) {
    SessionExpiredException() => l10n.errorSessionExpired,
    SyncReceiveException() => l10n.errorSyncReceive,
    SyncSendException() => l10n.errorSyncSend,
    NotAuthenticatedException() => l10n.errorNotAuthenticated,
    ServerUnavailableException() => l10n.errorServerUnavailable,
    AdminForbiddenException() => l10n.errorAdminForbidden,
    AuthFailedException(:final serverMessage, :final isRegistration) =>
      serverMessage ??
          (isRegistration ? l10n.errorRegisterFailed : l10n.errorLoginFailed),
    ServerErrorException(:final serverMessage) =>
      serverMessage ?? l10n.errorServerCommunication,
    SpeciesInUseException() => l10n.errorSpeciesInUse,
    SoilInUseException() => l10n.errorSoilInUse,
    LocationServiceException(:final error) => switch (error) {
        LocationError.unsupportedPlatform => l10n.locationUnsupportedPlatform,
        LocationError.serviceDisabled => l10n.locationServiceDisabled,
        LocationError.permissionDenied => l10n.locationPermissionDenied,
        LocationError.permissionDeniedForever =>
          l10n.locationPermissionDeniedForever,
      },
    _ => '$error',
  };
}
