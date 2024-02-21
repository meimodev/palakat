import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInRadiologyVirtualQueueState {
  final List<PatientJourney> journeys;

  SelfCheckInRadiologyVirtualQueueState({required this.journeys});

  SelfCheckInRadiologyVirtualQueueState copyWith({
    List<PatientJourney>? journeys,
  }) =>
      SelfCheckInRadiologyVirtualQueueState(
        journeys: journeys ?? this.journeys,
      );
}
