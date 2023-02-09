import 'package:jiffy/jiffy.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/services/firestrore_services.dart';

abstract class EventRepoContract {
  Future<List<Event>> readEventsThisWeek(String churchId);
}

class EventRepo implements EventRepoContract {
  final firestore = FirestoreService();

  @override
  Future<List<Event>> readEventsThisWeek(String churchId) async {
    final res = await firestore.getEvents(
      churchId: churchId,
      from: Jiffy().startOf(Units.WEEK).dateTime,
      to: Jiffy().endOf(Units.WEEK).dateTime,
    );
    final data =
        res.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();

    return data;
  }

  Future<List<Event>> readEventByAuthor({required String userId}) async {
    final res = await firestore.getEventsByUserId(userId: userId);
    final data =
        res.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();
    return data;
  }

  // create event & edit event
  Future<Event> writeEvent(Event event) async {
    final res = await firestore.setEvent(event.toMap());
    final data = Event.fromMap(res as Map<String, dynamic>);
    return data;
  }

  Future<Event> editEvent(Event event) async {
    final res = await firestore.editEvent(event.toMap());
    final data = Event.fromMap(res as Map<String, dynamic>);
    return data;
  }
}
