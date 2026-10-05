/// What a `polypodium://` link asks for. [agenda] and [plant] open the app
/// (home-screen widget taps, plant labels scanned in or out of the app);
/// [water] and [refresh] run in the background for the widget.
enum AppLinkType { agenda, plant, water, refresh }

/// A parsed `polypodium://` link. The single parser for every link the app
/// sends or receives.
class AppLink {
  const AppLink(this.type, [this.plantId]);

  final AppLinkType type;

  /// Set for [AppLinkType.plant] and [AppLinkType.water].
  final String? plantId;

  static const scheme = 'polypodium';

  /// The link printed on a plant's label: `polypodium://plant/<id>`.
  static Uri plantUri(String plantId) => Uri(
      scheme: scheme, host: AppLinkType.plant.name, pathSegments: [plantId]);

  /// `polypodium://agenda`, `polypodium://plant/<id>` (labels),
  /// `polypodium://plant?id=…` and `polypodium://water?id=…` (widget),
  /// `polypodium://refresh`. Null for anything else.
  static AppLink? parse(Uri? uri) {
    if (uri == null || uri.scheme != scheme) return null;
    final type = AppLinkType.values.asNameMap()[uri.host];
    if (type == null) return null;
    final needsPlant = type == AppLinkType.plant || type == AppLinkType.water;
    if (!needsPlant) return AppLink(type);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final id = switch (segments) {
      [final id] => id,
      [] => uri.queryParameters['id'],
      _ => null,
    };
    if (id == null || id.isEmpty) return null;
    return AppLink(type, id);
  }

  /// [parse] for text read from a QR code.
  static AppLink? tryParse(String? text) {
    final uri = Uri.tryParse(text?.trim() ?? '');
    return uri == null ? null : parse(uri);
  }
}
