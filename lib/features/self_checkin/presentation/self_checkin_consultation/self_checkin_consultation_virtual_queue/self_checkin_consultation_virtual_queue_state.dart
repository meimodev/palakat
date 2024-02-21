import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInConsultationVirtualQueueState {
  final List<PatientJourney> journeys;
  SelfCheckInConsultationVirtualQueueState({required this.journeys});

  SelfCheckInConsultationVirtualQueueState copyWith({
    List<PatientJourney>? journeys,
  }) =>
      SelfCheckInConsultationVirtualQueueState(
        journeys: journeys ?? this.journeys,
      );
}
