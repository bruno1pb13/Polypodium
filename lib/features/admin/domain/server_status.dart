class ServerStatus {
  final int uptimeSeconds;
  final String version;
  final int userCount;

  const ServerStatus({
    required this.uptimeSeconds,
    required this.version,
    required this.userCount,
  });

  factory ServerStatus.fromJson(Map<String, dynamic> json) => ServerStatus(
        uptimeSeconds: json['uptimeSeconds'] as int,
        version: json['version'] as String,
        userCount: json['userCount'] as int,
      );
}
