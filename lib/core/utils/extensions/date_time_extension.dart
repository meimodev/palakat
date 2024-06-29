// import 'package:flutter/material.dart';
// import 'package:palakat/core/utils/utils.dart';

import 'package:jiffy/jiffy.dart';

extension XDateTime on DateTime {
  Jiffy get toJiffy => Jiffy.parseFromDateTime(this);

  String toStringFormatted(String format) {
    return toJiffy.format(pattern: format);
  }

  bool isSameDay(DateTime dateTime) {
    return toJiffy.isSame(
      Jiffy.parseFromDateTime(dateTime),
      unit: Unit.day,
    );
  }

  bool isOnThisWeek(DateTime dateTime) {
    return Jiffy.parseFromDateTime(dateTime).isBetween(
      toJiffy.startOf(Unit.week),
      toJiffy.endOf(Unit.week),
    );
  }

  DateTime get toStartOfTheWeek {
    return toJiffy.startOf(Unit.week).dateTime;
  }
  DateTime get toEndOfTheWeek {
    return toJiffy.endOf(Unit.week).dateTime;
  }


  // String get monthAsMMM {
  //   return DateFormat.MMM().format(this);
  // }

  /// 24/01/2002
  String get slashDate {
    return toStringFormatted('dd/MM/yyyy');
  }

  // ignore: non_constant_identifier_names
  String get EEEEddMMMyyyy {
    return toStringFormatted('EEEE, dd MMMM yyyy');
  }

  // ignore: non_constant_identifier_names
  String get EddMMMyyyy {
    return toStringFormatted('E, dd MMMM yyyy');
  }

  //
  // String get yyyMMdd {
  //   return DateFormat('yyyy-MM-dd').format(this);
  // }
  //
  // String get mMddyyy {
  //   return DateFormat('MMM, dd yyyy').format(this);
  // }
  //
  /// 10 December 2019
  String get ddMmmmYyyy {
    return toStringFormatted('dd MMMM yyyy');
  }

  //
  // String get mmmddyyy {
  //   return DateFormat('MMM dd, yy').format(this);
  // }
  //
  // String get hhMmAa {
  //   return DateFormat('HH:mm aa').format(this);
  // }
  //

  // ignore: non_constant_identifier_names
  String get HHmm {
    return toStringFormatted('HH:mm');
  }

  //
  // String get mMMMddyyy {
  //   return DateFormat('MMMM dd, yyyy').format(this);
  // }
  //
  // String get mMMYyyy {
  //   return DateFormat('MMMM, yyyy').format(this);
  // }
  //
  // /// Tuesday, 10 Dec 2019
  // String get eeeeDMmmYyyy {
  //   return DateFormat('EEEE, d MMM yyyy').format(this);
  // }
  //
  // /// 10 Dec 2019 15:00
  // String get dMmmYyyyHhMm {
  //   return DateFormat('d MMM yyyy HH:mm').format(this);
  // }
  //
  // /// Thu, 10 Dec 2019 | 15:00
  // String get eeeDMmmYyyyHhMm {
  //   return DateFormat('EEE, MMMM d yyyy | HH:mm').format(this);
  // }
  //

  DateTime addDay({int days = 0}) {
    return add(Duration(days: days));
  }

  DateTime setTime(String timeString) {
    // Parse the time string to get hours and minutes
    List<String> parts = timeString.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Create a new DateTime with the same date and the specified time
    DateTime newDateTime = DateTime(
      year,
      month,
      day,
      hours,
      minutes,
    );

    return newDateTime;
  }

  DateTime setHour(int newHour, {bool isMinuteZero = false}) {
    return DateTime(
      year,
      month,
      day,
      newHour,
      isMinuteZero ? 0 : minute,
      isMinuteZero ? 0 : second,
      isMinuteZero ? 0 : millisecond,
      isMinuteZero ? 0 : microsecond,
    );
  }

  String get timeZoneLabel {
    switch (timeZoneOffset.inHours) {
      case 7:
        return "WIB";
      case 8:
        return "WITA";
      case 9:
        return "WIT";
      default:
        return timeZoneName;
    }
  }
}

// extension XDateTimeRange on DateTimeRange {
//   String toLabel({bool isShowTz = false}) {
//     final startClock = "${start.hour.toTwoDigits}:${start.minute.toTwoDigits}";
//     final endClock = "${end.hour.toTwoDigits}:${end.minute.toTwoDigits}";
//     final tzLabel = isShowTz ? "(${start.timeZoneLabel})" : "";
//
//     return "$startClock - $endClock $tzLabel";
//   }
// }
