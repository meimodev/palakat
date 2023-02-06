
import 'package:jiffy/jiffy.dart';

extension StringExtension on String {
  String cleanPhone({bool useCountryCode = false}) {
    trim();
    if (useCountryCode) {
      return startsWith("0") ? replaceFirst('0', '+62') : this;
    }
    return contains('+62') ? replaceFirst('+62', '0') : this;
  }

  bool statusStringToBool(){
    return !toLowerCase().contains("belum");
  }

  String toTitleCase(){

    if (length <= 1) {
      return toUpperCase();
    }

    // Split string into multiple words
    final List<String> words = split(' ');

    // Capitalize first letter of each words
    final capitalizedWords = words.map((word) {
      if (word.trim().isNotEmpty) {
        final String firstLetter = word.trim().substring(0, 1).toUpperCase();
        final String remainingLetters = word.trim().substring(1);

        return '$firstLetter$remainingLetters';
      }
      return '';
    });

    // Join/Merge all words back to one String
    return capitalizedWords.join(' ');
  }
}

extension BooleanExtension on bool {
  String statusBoolToString(String actionName){
    return this ? actionName : "Belum $actionName";
  }
}

extension DateTimeExtension on DateTime {
  String get toDayEEEE {
    return Jiffy(this).format("EEEE");
  }

  String get toMonthM {
    return Jiffy(this).format("M");
  }

  String get toMonthMMM {
    return Jiffy(this).format("MMM");
  }
  String get toMonthMMMM {
    return Jiffy(this).format("MMMM");
  }

  String get toTimeHHmm {
    return Jiffy(this).format("HH:mm");
  }

  String get toYeary {
    return Jiffy(this).format("y");
  }

  String get toDated {
    return Jiffy(this).format("d");
  }
  String format(String format){
    return Jiffy(this).format(format);
  }

  DateTime resetTimeToStartOfTheDay(){
    return Jiffy(this).startOf(Units.DAY).dateTime;
  }
}
