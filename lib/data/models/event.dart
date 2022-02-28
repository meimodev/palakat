import 'package:jiffy/jiffy.dart';

class Event {
  String id;
  String title;
  String location;
  String authorName;
  String authorPhone;
  String dateTime;
  List<String> reminders;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.authorName,
    required this.authorPhone,
    required this.dateTime,
    required this.reminders,
  });

  String get day {
    return dateTime.substring(0, dateTime.length - 18);
  }

  String get formattedDate {
    String s = dateTime.substring(dateTime.length - 16);
    return s.substring(0, 10);
  }

  String get time {
    return dateTime.substring(dateTime.length - 5);
  }

  String get year {
    return dateTime.substring(dateTime.length - 10, dateTime.length - 6);
  }

  String get date {
    String s = dateTime.substring(0, dateTime.length - 6);
    Jiffy jiffy = Jiffy(s, 'EEEE, dd/MM/y');
    return jiffy.format('EEEE, dd MMM');
  }
}