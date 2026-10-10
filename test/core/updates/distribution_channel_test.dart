import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/updates/distribution_channel.dart';

DistributionChannel resolve({
  required String os,
  String build = '',
  String exe = '',
  Map<String, String> env = const {},
  bool release = true,
}) =>
    resolveDistributionChannel(
      operatingSystem: os,
      buildChannel: build,
      executablePath: exe,
      environment: env,
      isRelease: release,
    );

void main() {
  test('debug builds never check for updates', () {
    expect(resolve(os: 'android', build: 'github', release: false),
        DistributionChannel.none);
    expect(resolve(os: 'linux', env: {'APPIMAGE': '/x'}, release: false),
        DistributionChannel.none);
  });

  test('Android follows the DIST_CHANNEL define, and without it stays out',
      () {
    expect(resolve(os: 'android', build: 'play'),
        DistributionChannel.playStore);
    expect(resolve(os: 'android', build: 'github'), DistributionChannel.github);
    expect(resolve(os: 'android'), DistributionChannel.none);
  });

  test('Windows tells the Store MSIX from the portable ZIP by install path',
      () {
    expect(
        resolve(
            os: 'windows',
            exe: r'C:\Program Files\WindowsApps\Polypodium_1.2.0.0_x64__abc'
                r'\polypodium.exe'),
        DistributionChannel.msStore);
    expect(resolve(os: 'windows', exe: r'D:\Apps\Polypodium\polypodium.exe'),
        DistributionChannel.github);
  });

  test('Linux checks GitHub only when running as an AppImage', () {
    expect(
        resolve(os: 'linux', env: {'APPIMAGE': '/home/u/Polypodium.AppImage'}),
        DistributionChannel.github);
    expect(resolve(os: 'linux'), DistributionChannel.none);
  });

  test('other platforms do not check', () {
    expect(resolve(os: 'macos'), DistributionChannel.none);
    expect(resolve(os: 'ios'), DistributionChannel.none);
  });
}
