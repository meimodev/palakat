import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookRadiologyChooseScheduleController
    extends StateNotifier<BookRadiologyChooseScheduleState> {
  BookRadiologyChooseScheduleController()
      : super(const BookRadiologyChooseScheduleState(selectedHospital: ""));

  void selectHospital(String? hospital) {
    state = state.copyWith(
      selectedHospital: hospital,
    );
  }
}

final bookRadiologyChooseScheduleControllerProvider =
    StateNotifierProvider.autoDispose<BookRadiologyChooseScheduleController,
        BookRadiologyChooseScheduleState>((ref) {
  return BookRadiologyChooseScheduleController();
});
