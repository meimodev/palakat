import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookMcuChooseScheduleController
    extends StateNotifier<BookMcuChooseScheduleState> {
  BookMcuChooseScheduleController()
      : super(const BookMcuChooseScheduleState(selectedHospital: ""));

  void selectHospital(String? hospital) {
    state = state.copyWith(
      selectedHospital: hospital,
    );
  }
}

final bookMcuChooseScheduleControllerProvider =
    StateNotifierProvider.autoDispose<BookMcuChooseScheduleController,
        BookMcuChooseScheduleState>((ref) {
  return BookMcuChooseScheduleController();
});
