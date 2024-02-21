import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookPhysiotherapyChooseScheduleController
    extends StateNotifier<BookPhysiotherapyChooseScheduleState> {
  BookPhysiotherapyChooseScheduleController()
      : super(const BookPhysiotherapyChooseScheduleState(selectedHospital: ""));

  void selectHospital(String? hospital) {
    state = state.copyWith(
      selectedHospital: hospital,
    );
  }
}

final bookPhysiotherapyChooseScheduleControllerProvider =
    StateNotifierProvider.autoDispose<BookPhysiotherapyChooseScheduleController,
        BookPhysiotherapyChooseScheduleState>((ref) {
  return BookPhysiotherapyChooseScheduleController();
});
