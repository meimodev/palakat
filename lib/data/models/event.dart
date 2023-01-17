import 'package:jiffy/jiffy.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/shared/values.dart';

class Event {
  String id;
  String title;
  String location;
  UserApp author;
  String dateTime;
  List<String> reminders;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.author,
    required this.dateTime,
    required this.reminders,
  });

  String get day {
    return Jiffy(dateTime, Values.eventDateTimeFormat).format("EEEE");
  }

  String get month {
    return Jiffy(dateTime, Values.eventDateTimeFormat).format("M");
  }
  String get monthF {
    return Jiffy(dateTime, Values.eventDateTimeFormat).format("MMM");
  }

  String get time {
    return Jiffy(dateTime, Values.eventDateTimeFormat).format("HH:mm");
  }

  String get year {
    return Jiffy(dateTime, Values.eventDateTimeFormat).format("y");
  }

  String get date {
    return Jiffy(dateTime, Values.eventDateTimeFormat).format("d");
  }
}