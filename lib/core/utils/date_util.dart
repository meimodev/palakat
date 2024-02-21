
class DateUtil {
  static List<DateTime> getDaysInNextNMonths(
    DateTime startingMonth, {
    int nMonth = 12,
    List<int> includeWeekDay = const [],
  }) {
    List<DateTime> daysInNextThreeMonths = [];
    DateTime currentMonth = DateTime(
      startingMonth.year,
      startingMonth.month,
      1,
    );

    for (int i = 0; i < nMonth; i++) {
      DateTime lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

      for (int j = currentMonth.day; j <= lastDay.day; j++) {
        DateTime temp = DateTime(currentMonth.year, currentMonth.month, j);

        if (includeWeekDay.contains(temp.weekday)) {
          daysInNextThreeMonths.add(temp);
        }
      }

      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    return daysInNextThreeMonths;
  }

  static List<int> replaceScheduleDayToWeekDays(List<int> scheduleDay) {
    return scheduleDay.map((e) => scheduleDayToWeekDay(e)).toList();
  }

  static int scheduleDayToWeekDay(int scheduleDay) {
    if (scheduleDay == 1) {
      return 7;
    }

    return scheduleDay - 1;
  }

  // static String labelWeekDay(int weekDay) {
  //   switch (weekDay) {
  //     case 1:
  //       return LocaleKeys.date_monday.tr();
  //     case 2:
  //       return LocaleKeys.date_tuesday.tr();
  //     case 3:
  //       return LocaleKeys.date_wednesday.tr();
  //     case 4:
  //       return LocaleKeys.date_thursday.tr();
  //     case 5:
  //       return LocaleKeys.date_friday.tr();
  //     case 6:
  //       return LocaleKeys.date_saturday.tr();
  //     default:
  //       return LocaleKeys.date_sunday.tr();
  //   }
  // }
}
