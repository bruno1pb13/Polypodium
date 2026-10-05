/// Typed sync/auth failures. Services throw these instead of user-facing
/// strings; the UI maps them to localized messages via
/// `localizedErrorMessage` in `core/l10n/error_messages.dart`.
class SessionExpiredException implements Exception {
  const SessionExpiredException();

  @override
  String toString() => 'SessionExpiredException';
}

class SyncReceiveException implements Exception {
  const SyncReceiveException();

  @override
  String toString() => 'SyncReceiveException';
}

class SyncSendException implements Exception {
  const SyncSendException();

  @override
  String toString() => 'SyncSendException';
}

/// The server refused a workspace's garden: the account was removed from it
/// (or left it on another device).
class GardenAccessDeniedException implements Exception {
  const GardenAccessDeniedException();

  @override
  String toString() => 'GardenAccessDeniedException';
}

/// The server predates shared gardens (`/gardens` doesn't exist).
class GardensUnsupportedException implements Exception {
  const GardensUnsupportedException();

  @override
  String toString() => 'GardensUnsupportedException';
}

/// Adding a garden member by an e-mail that has no account on the server.
class GardenAccountNotFoundException implements Exception {
  const GardenAccountNotFoundException();

  @override
  String toString() => 'GardenAccountNotFoundException';
}

/// Adding a garden member who already belongs to it.
class GardenAlreadyMemberException implements Exception {
  const GardenAlreadyMemberException();

  @override
  String toString() => 'GardenAlreadyMemberException';
}

class NotAuthenticatedException implements Exception {
  const NotAuthenticatedException();

  @override
  String toString() => 'NotAuthenticatedException';
}

class ServerUnavailableException implements Exception {
  const ServerUnavailableException();

  @override
  String toString() => 'ServerUnavailableException';
}

class AdminForbiddenException implements Exception {
  const AdminForbiddenException();

  @override
  String toString() => 'AdminForbiddenException';
}

/// Login/registration rejected. [serverMessage] carries the server-provided
/// reason when there is one; the UI falls back to a localized generic text.
class AuthFailedException implements Exception {
  final String? serverMessage;
  final bool isRegistration;
  const AuthFailedException({this.serverMessage, this.isRegistration = false});

  @override
  String toString() => serverMessage ?? 'AuthFailedException';
}

/// Any other non-2xx server response. [serverMessage] carries the
/// server-provided reason when there is one.
class ServerErrorException implements Exception {
  final String? serverMessage;
  const ServerErrorException([this.serverMessage]);

  @override
  String toString() => serverMessage ?? 'ServerErrorException';
}
