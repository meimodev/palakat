import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInVaccineImmunizationVirtualQueueController
    extends StateNotifier<SelfCheckInVaccineImmunizationVirtualQueueState> {
  SelfCheckInVaccineImmunizationVirtualQueueController(
      {required List<PatientJourney> journeys})
      : super(SelfCheckInVaccineImmunizationVirtualQueueState(
            journeys: journeys));

  void updateList(PatientJourney data, int index) {
    final list = [...state.journeys];
    list.removeAt(index);
    list.add(data);
    state = state.copyWith(journeys: list);
  }
}

final selfCheckInVaccineImmunizationVirtualQueueController =
    StateNotifierProvider.autoDispose.family<
        SelfCheckInVaccineImmunizationVirtualQueueController,
        SelfCheckInVaccineImmunizationVirtualQueueState,
        List<PatientJourney>>((
  ref,
  journeys,
) {
  return SelfCheckInVaccineImmunizationVirtualQueueController(
      journeys: journeys);
});
