import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInMCUVirtualQueueController
    extends StateNotifier<SelfCheckInMCUVirtualQueueState> {
  SelfCheckInMCUVirtualQueueController(
      {required List<PatientJourney> journeys})
      : super(SelfCheckInMCUVirtualQueueState(journeys: journeys));

  void updateList(PatientJourney data, int index) {
    final list = [...state.journeys];
    list.removeAt(index);
    list.add(data);
    state = state.copyWith(journeys: list);
  }
}

final selfCheckInMCUVirtualQueueController =
    StateNotifierProvider.autoDispose.family<
        SelfCheckInMCUVirtualQueueController,
        SelfCheckInMCUVirtualQueueState,
        List<PatientJourney>>((
  ref,
  journeys,
) {
  return SelfCheckInMCUVirtualQueueController(journeys: journeys);
});
