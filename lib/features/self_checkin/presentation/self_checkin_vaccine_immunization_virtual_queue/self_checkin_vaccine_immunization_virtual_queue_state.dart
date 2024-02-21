import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInVaccineImmunizationVirtualQueueState {
  final List<PatientJourney> journeys;

  SelfCheckInVaccineImmunizationVirtualQueueState({required this.journeys});

  SelfCheckInVaccineImmunizationVirtualQueueState copyWith({
    List<PatientJourney>? journeys,
  }) =>
      SelfCheckInVaccineImmunizationVirtualQueueState(
        journeys: journeys ?? this.journeys,
      );
}
