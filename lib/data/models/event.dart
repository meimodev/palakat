import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palakat/data/models/user_app.dart';

class Event {
  String id;
  String title;
  String location;
  UserApp? author;
  String authorId;

  DateTime eventDateTimeStamp;
  List<String> reminders;

  Event({
    required this.id,
    required this.title,
    required this.location,
    this.author,
    required this.authorId,
    required this.eventDateTimeStamp,
    required this.reminders,
  });

  factory Event.fromMap(Map<String, dynamic> data) => Event(
        id: data["id"],
        title: data["title"],
        location: data["location"],
        authorId: data["user_id"],
        eventDateTimeStamp:
            (data["event_date_time_stamp"] as Timestamp).toDate(),
        reminders: List<String>.from(data["reminders"]),
      );


}
