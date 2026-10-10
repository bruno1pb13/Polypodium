import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'update_checker.dart';

/// Release asset each platform downloads, as published by release.yml.
String? githubAssetFor(String operatingSystem) => switch (operatingSystem) {
      'android' => 'app-release.apk',
      'windows' => 'Polypodium-Windows-Portable.zip',
      'linux' => 'Polypodium-x86_64.AppImage',
      _ => null,
    };

/// Compares the latest GitHub release with the running version. Builds
/// installed by hand (APK, portable ZIP, AppImage) update this way; the
/// download opens in the browser and the user installs it.
class GithubUpdateChecker implements UpdateChecker {
  GithubUpdateChecker({
    required this.currentVersion,
    required this.assetName,
    this.repository = 'bruno1pb13/Polypodium',
    Future<bool> Function(Uri url)? openUrl,
  }) : _openUrl = openUrl ??
            ((url) => launchUrl(url, mode: LaunchMode.externalApplication));

  final String currentVersion;
  final String? assetName;
  final String repository;
  final Future<bool> Function(Uri url) _openUrl;

  @override
  Future<AvailableUpdate?> check() async {
    // /latest already skips drafts and pre-releases.
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$repository/releases/latest'),
      headers: {'Accept': 'application/vnd.github+json'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw http.ClientException(
          'GitHub releases: HTTP ${response.statusCode}');
    }

    final release = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = release['tag_name'] as String;
    if (!isNewerVersion(tag, currentVersion)) return null;

    final assets = (release['assets'] as List).cast<Map<String, dynamic>>();
    final asset = assets.where((a) => a['name'] == assetName).firstOrNull;
    final url = (asset?['browser_download_url'] ?? release['html_url'])
        as String;
    return AvailableUpdate(
      id: tag,
      version: normalizeVersion(tag),
      downloadUrl: Uri.parse(url),
    );
  }

  @override
  Future<void> install(AvailableUpdate update) async {
    await _openUrl(update.downloadUrl!);
  }
}

/// `v1.2.3`, the legacy `v.1.2.3` and `1.2.3+4` all become `1.2.3`.
String normalizeVersion(String version) {
  var v = version.trim();
  if (v.startsWith('v')) v = v.substring(1);
  if (v.startsWith('.')) v = v.substring(1);
  return v.split('+').first;
}

/// Whether [candidate] is a higher x.y.z version than [current]. Versions
/// that don't parse are never newer, so a malformed tag can't nag the user.
bool isNewerVersion(String candidate, String current) {
  final a = _parts(candidate);
  final b = _parts(current);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return false;
}

List<int>? _parts(String version) {
  final match =
      RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(normalizeVersion(version));
  if (match == null) return null;
  return [for (var i = 1; i <= 3; i++) int.parse(match.group(i)!)];
}
