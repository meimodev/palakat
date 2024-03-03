// import 'package:flutter/material.dart';
// import 'package:palakat/core/utils/utils.dart';

extension XDateTime on DateTime {
  // String get monthAsMMM {
  //   return DateFormat.MMM().format(this);
  // }
  //
  // String get slashDate {
  //   return DateFormat('dd/MM/yyyy').format(this);
  // }
  //
  // String get yyyMMdd {
  //   return DateFormat('yyyy-MM-dd').format(this);
  // }
  //
  // String get mMddyyy {
  //   return DateFormat('MMM, dd yyyy').format(this);
  // }
  //
  // /// 10 December 2019
  // String get ddMmmmYyyy {
  //   return DateFormat('dd MMMM yyyy').format(this);
  // }
  //
  // String get mmmddyyy {
  //   return DateFormat('MMM dd, yy').format(this);
  // }
  //
  // String get hhMmAa {
  //   return DateFormat('HH:mm aa').format(this);
  // }
  //
  // String get hhMm {
  //   return DateFormat('HH:mm').format(this);
  // }
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
  // String toStringFormatted({String format = 'dd/MM/yyyy'}) {
  //   return DateFormat(format).format(this);
  // }

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
