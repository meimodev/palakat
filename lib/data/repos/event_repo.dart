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

  streamEventsByAuthor({required String userId}) async  {
    //hevavy coupled to firestore, fix this later
    final res = await firestore.streamEventsByUserId(userId: userId);
    return res;
  }

  // create event & edit event
  Future<void> writeEvent(Event event) async {
     await firestore.setEvent(event.toMap());
  }

  Future<Event> editEvent(Event event) async {
    final res = await firestore.editEvent(event.toMap());
    final data = Event.fromMap(res as Map<String, dynamic>);
    return data;
  }
}
