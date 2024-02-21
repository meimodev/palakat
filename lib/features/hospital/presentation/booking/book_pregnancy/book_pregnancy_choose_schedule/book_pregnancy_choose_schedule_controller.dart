import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookPregnancyChooseScheduleController
    extends StateNotifier<BookPregnancyChooseScheduleState> {
  BookPregnancyChooseScheduleController()
      : super(const BookPregnancyChooseScheduleState(selectedHospital: ""));

  void selectHospital(String? hospital) {
    state = state.copyWith(
      selectedHospital: hospital,
    );
  }
}

final bookPregnancyChooseScheduleControllerProvider =
    StateNotifierProvider.autoDispose<BookPregnancyChooseScheduleController,
        BookPregnancyChooseScheduleState>((ref) {
  return BookPregnancyChooseScheduleController();
});
