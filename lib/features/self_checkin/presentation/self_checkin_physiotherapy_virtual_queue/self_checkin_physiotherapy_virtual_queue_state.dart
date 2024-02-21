import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInPhysiotherapyVirtualQueueState {
  final List<PatientJourney> journeys;

  SelfCheckInPhysiotherapyVirtualQueueState({required this.journeys});

  SelfCheckInPhysiotherapyVirtualQueueState copyWith({
    List<PatientJourney>? journeys,
  }) =>
      SelfCheckInPhysiotherapyVirtualQueueState(
        journeys: journeys ?? this.journeys,
      );
}
