import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInPregnancyExerciseVirtualQueueState {
  final List<PatientJourney> journeys;

  SelfCheckInPregnancyExerciseVirtualQueueState({required this.journeys});

  SelfCheckInPregnancyExerciseVirtualQueueState copyWith({
    List<PatientJourney>? journeys,
  }) =>
      SelfCheckInPregnancyExerciseVirtualQueueState(
        journeys: journeys ?? this.journeys,
      );
}
