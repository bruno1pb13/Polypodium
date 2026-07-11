/// Typed domain failures surfaced to the user. The UI maps them to
/// localized messages via `localizedErrorMessage` in
/// `core/l10n/error_messages.dart`.
class SpeciesInUseException implements Exception {
  const SpeciesInUseException();

  @override
  String toString() => 'SpeciesInUseException';
}

class SoilInUseException implements Exception {
  const SoilInUseException();

  @override
  String toString() => 'SoilInUseException';
}
