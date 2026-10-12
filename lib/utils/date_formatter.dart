import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _fullDateFormatter = DateFormat('MMM d, y');
  static final DateFormat _timeFormatter = DateFormat('h:mm a');

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      return DateFormat('EEEE').format(date); // e.g. "Friday"
    } else {
      return _fullDateFormatter.format(date);
    }
  }

  static String formatDetailed(DateTime date) {
    return _fullDateFormatter.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }
}
