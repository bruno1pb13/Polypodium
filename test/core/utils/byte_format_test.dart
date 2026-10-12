import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/utils/byte_format.dart';

void main() {
  test('picks the unit and the locale decimal separator', () {
    expect(formatBytes(0, 'pt'), '0 B');
    expect(formatBytes(1023, 'pt'), '1023 B');
    expect(formatBytes(1536, 'pt'), '2 KB');
    expect(formatBytes(5 * 1024 * 1024 + 300 * 1024, 'pt'), '5,3 MB');
    expect(formatBytes(5 * 1024 * 1024 + 300 * 1024, 'en'), '5.3 MB');
    expect(formatBytes(3 * 1024 * 1024 * 1024, 'en'), '3.0 GB');
  });
}
