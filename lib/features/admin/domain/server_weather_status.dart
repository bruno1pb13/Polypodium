/// Summary of `GET /api/v1/admin/weather`: the regions the server keeps
/// forecasts for (nearby locations share one) and how fetching is going.
class ServerWeatherStatus {
  const ServerWeatherStatus({
    required this.enabled,
    required this.regionCount,
    required this.failingRegionCount,
    this.lastFetchedAt,
  });

  final bool enabled;
  final int regionCount;

  /// Regions whose most recent fetch attempt failed.
  final int failingRegionCount;

  /// Most recent successful fetch across all regions.
  final DateTime? lastFetchedAt;

  factory ServerWeatherStatus.fromJson(Map<String, dynamic> json) {
    final regions =
        (json['regions'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    DateTime? last;
    for (final r in regions) {
      final at = DateTime.tryParse(r['lastFetchedAt'] as String? ?? '');
      if (at != null && (last == null || at.isAfter(last))) last = at;
    }
    return ServerWeatherStatus(
      enabled: json['enabled'] as bool? ?? false,
      regionCount: regions.length,
      failingRegionCount: regions.where((r) => r['lastError'] != null).length,
      lastFetchedAt: last?.toLocal(),
    );
  }
}
