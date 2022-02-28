part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
}

class LoadEvents extends EventEvent {
  final List<Event> events;

  const LoadEvents({this.events = const []});
  @override
  List<Object?> get props => [events];
}

class LoadThisWeekEvents extends EventEvent {
  final List<Event> eventsThisWeek;

  const LoadThisWeekEvents({this.eventsThisWeek = const []});
  @override
  List<Object?> get props => [eventsThisWeek];
}

class AddEvent extends EventEvent {
  final Event event;

  const AddEvent({required this.event});
  @override
  List<Object?> get props => [event];
}

class UpdateEvent extends EventEvent {
  final Event event;

  const UpdateEvent({required this.event});
  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends EventEvent {
  final Event event;

  const DeleteEvent({required this.event});
  @override
  List<Object?> get props => [event];
}