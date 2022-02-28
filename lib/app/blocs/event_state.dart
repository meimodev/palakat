part of 'event_bloc.dart';

abstract class EventState extends Equatable {
  const EventState();
}

class EventLoading extends EventState {
  @override
  List<Object> get props => [];
}

class EventLoaded extends EventState {
  final List<Event> events;
  final List<Event> eventsThisWeek;

  const EventLoaded({
    this.events = const [],
    this.eventsThisWeek = const [],
  });

  @override
  List<Object?> get props => [events];

  List<Event> eventsWithAuthor(String authorPhone) {
    return events
        .where((element) => element.authorPhone == authorPhone)
        .toList();
  }

  List<Event> getEventsThisWeek() {
    return [];
  }
}