import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInMCUVirtualQueueState {
  final List<PatientJourney> journeys;

  SelfCheckInMCUVirtualQueueState({required this.journeys});

  SelfCheckInMCUVirtualQueueState copyWith({
    List<PatientJourney>? journeys,
  }) =>
      SelfCheckInMCUVirtualQueueState(
        journeys: journeys ?? this.journeys,
      );
}
