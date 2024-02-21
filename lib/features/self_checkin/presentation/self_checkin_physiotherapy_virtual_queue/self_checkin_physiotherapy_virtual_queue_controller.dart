import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInPhysiotherapyVirtualQueueController
    extends StateNotifier<SelfCheckInPhysiotherapyVirtualQueueState> {
  SelfCheckInPhysiotherapyVirtualQueueController(
      {required List<PatientJourney> journeys})
      : super(SelfCheckInPhysiotherapyVirtualQueueState(journeys: journeys));

  void updateList(PatientJourney data, int index) {
    final list = [...state.journeys];
    list.removeAt(index);
    list.add(data);
    state = state.copyWith(journeys: list);
  }
}

final selfCheckInPhysiotherapyVirtualQueueController =
    StateNotifierProvider.autoDispose.family<
        SelfCheckInPhysiotherapyVirtualQueueController,
        SelfCheckInPhysiotherapyVirtualQueueState,
        List<PatientJourney>>((
  ref,
  journeys,
) {
  return SelfCheckInPhysiotherapyVirtualQueueController(journeys: journeys);
});
