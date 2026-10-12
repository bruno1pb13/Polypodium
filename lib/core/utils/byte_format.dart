import 'package:intl/intl.dart';

/// [bytes] in the largest unit that keeps it at 1 or more (B up to GB),
/// with one decimal from MB on, in [locale]'s number format.
String formatBytes(int bytes, String locale) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final pattern = unit >= 2 ? '0.0' : '0';
  return '${NumberFormat(pattern, locale).format(value)} ${units[unit]}';
}
