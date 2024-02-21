import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInRadiologyVirtualQueueController
    extends StateNotifier<SelfCheckInRadiologyVirtualQueueState> {
  SelfCheckInRadiologyVirtualQueueController(
      {required List<PatientJourney> journeys})
      : super(SelfCheckInRadiologyVirtualQueueState(journeys: journeys));

  void updateList(PatientJourney data, int index) {
    final list = [...state.journeys];
    list.removeAt(index);
    list.add(data);
    state = state.copyWith(journeys: list);
  }
}

final selfCheckInRadiologyVirtualQueueController =
    StateNotifierProvider.autoDispose.family<
        SelfCheckInRadiologyVirtualQueueController,
        SelfCheckInRadiologyVirtualQueueState,
        List<PatientJourney>>((
  ref,
  journeys,
) {
  return SelfCheckInRadiologyVirtualQueueController(journeys: journeys);
});
