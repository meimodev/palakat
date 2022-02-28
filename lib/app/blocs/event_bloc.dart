import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/data/models/event.dart';

part 'event_event.dart';

part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc() : super(EventLoading()) {
    on<LoadEvents>(_onLoadEvents);
    on<AddEvent>(_onAddEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<UpdateEvent>(_onUpdateEvent);
  }

  void _onLoadEvents(LoadEvents event, Emitter<EventState> emit) {
    emit(EventLoaded(
      events: event.events,
      eventsThisWeek: event.events
          .where((element) => checkIfEventOnThisWeek(element))
          .toList(),
    ));
  }

  void _onAddEvent(AddEvent event, Emitter<EventState> emit) {
    final state = this.state;
    if (state is EventLoaded) {
      List<Event> eventsThisWeek = List.from(state.eventsThisWeek);
      if (checkIfEventOnThisWeek(event.event)) {
        eventsThisWeek.add(event.event);
      }
      emit(
        EventLoaded(
          events: List.from(state.events)..add(event.event),
          eventsThisWeek: eventsThisWeek,
        ),
      );
    }
  }

  void _onDeleteEvent(DeleteEvent event, Emitter<EventState> emit) {}

  void _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) {}

  bool checkIfEventOnThisWeek(Event e) {
    Jiffy startDate = Jiffy().startOf(Units.WEEK);
    Jiffy endDate = Jiffy().endOf(Units.WEEK).add(days: 1);

    Jiffy date = Jiffy(e.dateTime, 'EEEE, dd/MM/y HH:mm');

    if (date.isBetween(startDate, endDate, Units.HOUR)) {
      return true;
    }
    return false;
  }
}