import 'package:intl/intl.dart';

class AppDateFormat {
  AppDateFormat._();

  static String dayMonth(DateTime date, String locale) => DateFormat.MMMd(locale).format(date);

  static String weekdayDayMonth(DateTime date, String locale) => DateFormat('EEE, MMM d', locale).format(date);

  static String fullDate(DateTime date, String locale) => DateFormat.yMMMMd(locale).format(date);

  static String monthYear(DateTime date, String locale) => DateFormat.yMMMM(locale).format(date);

  static String time(int minutesFromMidnight, String locale) {
    final dt = DateTime(2000, 1, 1).add(Duration(minutes: minutesFromMidnight));
    return DateFormat.jm(locale).format(dt);
  }
}
