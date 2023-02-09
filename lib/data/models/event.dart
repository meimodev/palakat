import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palakat/data/models/user_app.dart';

class Event {
  String id;
  String title;
  String location;
  UserApp? author;
  String authorId;
  String churchId;

  DateTime eventDateTimeStamp;
  List<String> reminders;

  Event({
    required this.id,
    required this.title,
    required this.location,
    this.author,
    required this.authorId,
    required this.churchId,
    required this.eventDateTimeStamp,
    required this.reminders,
  });

  factory Event.fromMap(Map<String, dynamic> data) => Event(
        id: data["id"],
        title: data["title"],
        location: data["location"],
        authorId: data["user_id"],
        churchId: data["church_id"],
        eventDateTimeStamp:
            (data["event_date_time_stamp"] as Timestamp).toDate(),
        reminders: List<String>.from(data["reminders"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "location": location,
        "user_id": authorId,
        "church_id": churchId,
        "event_date_time_stamp": eventDateTimeStamp,
        "reminders": reminders,
      };

  @override
  String toString() {
    return 'Event{id: $id, title: $title, location: $location, author: $author, authorId: $authorId,authorId: $churchId, eventDateTimeStamp: $eventDateTimeStamp, reminders: $reminders}';
  }
}
