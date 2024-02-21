import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookLaboratoryChooseScheduleController
    extends StateNotifier<BookLaboratoryChooseScheduleState> {
  BookLaboratoryChooseScheduleController()
      : super(const BookLaboratoryChooseScheduleState(selectedHospital: ""));

  void selectHospital(String? hospital) {
    state = state.copyWith(
      selectedHospital: hospital,
    );
  }
}

final bookLaboratoryChooseScheduleControllerProvider =
    StateNotifierProvider.autoDispose<BookLaboratoryChooseScheduleController,
        BookLaboratoryChooseScheduleState>((ref) {
  return BookLaboratoryChooseScheduleController();
});
