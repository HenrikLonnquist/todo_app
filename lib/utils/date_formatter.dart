import 'package:intl/intl.dart';

class CalendarDateFormatter {

  CalendarDateFormatter._();

  static String shortDay(DateTime date) {
    return DateFormat("E").format(date);
  }

  static String dayName(DateTime date) {
    return DateFormat("EEEE").format(date);
  }

  static String monthName(DateTime date) {
    return DateFormat("MMM").format(date);
  }

  static String fullDate(DateTime date) {
    return DateFormat("y-MM-d").format(date);
  }

  static Map<String, String> parseAll(DateTime date){
    return {
      "shortDay": shortDay(date),
      "dayName": dayName(date),
      "monthName": monthName(date),
    };
  }
  
}