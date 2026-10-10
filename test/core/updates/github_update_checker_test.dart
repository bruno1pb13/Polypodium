import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polypodium/core/updates/github_update_checker.dart';

Map<String, dynamic> _release(String tag) => {
      'tag_name': tag,
      'html_url': 'https://github.com/o/r/releases/tag/$tag',
      'assets': [
        {
          'name': 'app-release.apk',
          'browser_download_url': 'https://github.com/o/r/app-release.apk',
        },
      ],
    };

Future<T> _withRelease<T>(Object body, Future<T> Function() action,
        {int status = 200, void Function(http.Request)? onRequest}) =>
    http.runWithClient(action, () => MockClient((request) async {
          onRequest?.call(request);
          return http.Response(jsonEncode(body), status);
        }));

void main() {
  group('isNewerVersion', () {
    test('compares x.y.z numerically, ignoring the v prefix and build', () {
      expect(isNewerVersion('v1.10.0', '1.9.3'), isTrue);
      expect(isNewerVersion('v.2.0.0', '1.9.9'), isTrue);
      expect(isNewerVersion('v1.2.0+7', '1.2.0'), isFalse);
      expect(isNewerVersion('v1.1.9', '1.2.0'), isFalse);
    });

    test('a malformed version is never newer', () {
      expect(isNewerVersion('nightly', '1.0.0'), isFalse);
      expect(isNewerVersion('v2.0', '1.0.0'), isFalse);
    });
  });

  test('offers the latest release asset for this platform', () async {
    late http.Request sent;
    final update = await _withRelease(
      _release('v1.3.0'),
      () => GithubUpdateChecker(
              currentVersion: '1.2.0',
              assetName: 'app-release.apk',
              repository: 'o/r')
          .check(),
      onRequest: (r) => sent = r,
    );

    expect(sent.url.toString(),
        'https://api.github.com/repos/o/r/releases/latest');
    expect(update!.id, 'v1.3.0');
    expect(update.version, '1.3.0');
    expect(update.downloadUrl.toString(),
        'https://github.com/o/r/app-release.apk');
  });

  test('falls back to the release page when the asset is missing', () async {
    final update = await _withRelease(
      _release('v1.3.0'),
      () => GithubUpdateChecker(
              currentVersion: '1.2.0',
              assetName: 'Polypodium-x86_64.AppImage',
              repository: 'o/r')
          .check(),
    );
    expect(update!.downloadUrl.toString(),
        'https://github.com/o/r/releases/tag/v1.3.0');
  });

  test('nothing to offer when already on the latest version', () async {
    final update = await _withRelease(
      _release('v1.2.0'),
      () => GithubUpdateChecker(currentVersion: '1.2.0', assetName: null)
          .check(),
    );
    expect(update, isNull);
  });

  test('throws when GitHub answers with an error', () async {
    await expectLater(
      _withRelease({'message': 'rate limited'},
          () => GithubUpdateChecker(currentVersion: '1.2.0', assetName: null)
              .check(),
          status: 403),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('install opens the download url', () async {
    Uri? opened;
    final checker = GithubUpdateChecker(
      currentVersion: '1.2.0',
      assetName: null,
      openUrl: (url) async {
        opened = url;
        return true;
      },
    );
    final update = await _withRelease(_release('v1.3.0'), checker.check);
    await checker.install(update!);
    expect(opened, update.downloadUrl);
  });
}
