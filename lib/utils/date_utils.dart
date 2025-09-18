import 'package:intl/intl.dart';

/// Pretty header like "Mon, 12 Aug 2025"
String prettyDateHeader(DateTime d) {
  return DateFormat('EEE, dd MMM yyyy').format(d);
}

/// Compact relative label for small UI: Today, 1d, 2d, 1w
String compactRelative(DateTime date) {
  final now = DateTime.now();
  final days = now.difference(DateTime(date.year, date.month, date.day)).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return '1d';
  if (days < 7) return '${days}d';
  final weeks = (days / 7).floor();
  return '${weeks}w';
}
