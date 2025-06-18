import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dayFormat = DateFormat('EEEE');
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  
  /// Format date to dd/MM/yyyy
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  /// Format time to HH:mm
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }
  
  /// Format date and time to dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
  
  /// Format day name (e.g., Monday)
  static String formatDayName(DateTime date) {
    return _dayFormat.format(date);
  }
  
  /// Format month and year (e.g., January 2024)
  static String formatMonthYear(DateTime date) {
    return _monthFormat.format(date);
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  /// Get relative date string (Today, Tomorrow, Yesterday, or formatted date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }
  
  /// Check if date is overdue (past today)
  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }
  
  /// Get days difference from today
  static int daysDifference(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.difference(today).inDays;
  }
  
  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
