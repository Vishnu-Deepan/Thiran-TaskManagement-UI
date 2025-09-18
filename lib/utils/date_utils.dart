import 'package:intl/intl.dart';

String prettyDateHeader(DateTime date) {
  return DateFormat('EEE, dd MMM yyyy').format(date);
}

/// Compact relative days: Today, Yesterday, 2d, 1w, 2m
String daysAgoCompact(DateTime date) {
  final now = DateTime.now();
  final days = now.difference(DateTime(date.year, date.month, date.day)).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return '${days}d';
  if (days < 30) return '${(days / 7).floor()}w';
  return '${(days / 30).floor()}m';
}
