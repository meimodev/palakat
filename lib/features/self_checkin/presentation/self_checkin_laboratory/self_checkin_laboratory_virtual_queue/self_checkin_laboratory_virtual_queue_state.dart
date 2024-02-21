import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInLaboratoryVirtualQueueState {
  final List<PatientJourney> journeys;

  SelfCheckInLaboratoryVirtualQueueState({required this.journeys});

  SelfCheckInLaboratoryVirtualQueueState copyWith({
    List<PatientJourney>? journeys,
  }) =>
      SelfCheckInLaboratoryVirtualQueueState(
        journeys: journeys ?? this.journeys,
      );
}
