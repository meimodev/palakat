import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInLaboratoryVirtualQueueController
    extends StateNotifier<SelfCheckInLaboratoryVirtualQueueState> {
  SelfCheckInLaboratoryVirtualQueueController(
    List<PatientJourney> journeys,
  ) : super(SelfCheckInLaboratoryVirtualQueueState(journeys: journeys));

  void updateList(PatientJourney journey, PatientJourney altered) {
    state = state.copyWith(journeys: [
      for (PatientJourney j in state.journeys)
        if (j == journey) altered else j
    ]);
  }
}

final selfCheckInLaboratoryVirtualQueueController =
    StateNotifierProvider.autoDispose.family<
        SelfCheckInLaboratoryVirtualQueueController,
        SelfCheckInLaboratoryVirtualQueueState,
        List<PatientJourney>>((
  ref,
  journeys,
) {
  return SelfCheckInLaboratoryVirtualQueueController(journeys);
});
