import 'package:intl/intl.dart';

class CalendarDateFormatter {

  CalendarDateFormatter._();

  static String shortDay(DateTime date) {
    return DateFormat("E").format(date);
  }

  static String dayName(date) {
    return DateFormat("EEEE").format(date);
  }

  static String monthName(DateTime date) {
    return DateFormat("MMM").format(date);
  }

  static String fullDate(DateTime date) {
    return DateFormat("y-MM-d").format(date);
  }
  
}