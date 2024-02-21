import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookVaccineChooseScheduleController
    extends StateNotifier<BookVaccineChooseScheduleState> {
  BookVaccineChooseScheduleController()
      : super(
          const BookVaccineChooseScheduleState(
            selectedHospital: "",
            selectedDoctor: "",
          ),
        );

  setSearchValue(String? text) {
    state = state.copyWith(searchValue: text);
  }

  void selectHospital(String? hospital) {
    state = state.copyWith(
      selectedHospital: hospital,
    );
  }

  void selectDoctor(String? doctor) {
    state = state.copyWith(
      selectedDoctor: doctor,
    );
  }
}

final bookVaccineChooseScheduleControllerProvider =
    StateNotifierProvider.autoDispose<BookVaccineChooseScheduleController,
        BookVaccineChooseScheduleState>((ref) {
  return BookVaccineChooseScheduleController();
});
