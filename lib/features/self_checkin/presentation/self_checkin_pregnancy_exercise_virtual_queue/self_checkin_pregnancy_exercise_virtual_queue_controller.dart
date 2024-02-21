import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

class SelfCheckInPregnancyExerciseVirtualQueueController
    extends StateNotifier<SelfCheckInPregnancyExerciseVirtualQueueState> {
  SelfCheckInPregnancyExerciseVirtualQueueController(
      {required List<PatientJourney> journeys})
      : super(SelfCheckInPregnancyExerciseVirtualQueueState(journeys: journeys));

  void updateList(PatientJourney data, int index) {
    final list = [...state.journeys];
    list.removeAt(index);
    list.add(data);
    state = state.copyWith(journeys: list);
  }
}

final selfCheckInPregnancyExerciseVirtualQueueController =
    StateNotifierProvider.autoDispose.family<
        SelfCheckInPregnancyExerciseVirtualQueueController,
        SelfCheckInPregnancyExerciseVirtualQueueState,
        List<PatientJourney>>((
  ref,
  journeys,
) {
  return SelfCheckInPregnancyExerciseVirtualQueueController(journeys: journeys);
});
