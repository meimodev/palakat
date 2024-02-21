import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInConsultationVirtualQueueController
    extends StateNotifier<SelfCheckInConsultationVirtualQueueState> {
  SelfCheckInConsultationVirtualQueueController(
    List<PatientJourney> journeys,
  ) : super(SelfCheckInConsultationVirtualQueueState(journeys: journeys));

  void updateList(PatientJourney journey, PatientJourney altered) {
    state = state.copyWith(journeys: [
      for (PatientJourney j in state.journeys)
        if (j == journey) altered else j
    ]);
  }
}

final selfCheckInConsultationVirtualQueueController =
    StateNotifierProvider.autoDispose.family<
        SelfCheckInConsultationVirtualQueueController,
        SelfCheckInConsultationVirtualQueueState,
        List<PatientJourney>>((
  ref,
  journeys,
) {
  return SelfCheckInConsultationVirtualQueueController(journeys);
});
