import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookVaccinePreScreeningController
    extends StateNotifier<BookVaccinePreScreeningState> {
  BookVaccinePreScreeningController()
      : super(BookVaccinePreScreeningState(isEligible: false));

  void changeEligibility(bool isEligible) {
    state = state.copyWith(isEligible: isEligible);
  }
}

final bookVaccinePreScreeningProvider = StateNotifierProvider.autoDispose<
    BookVaccinePreScreeningController, BookVaccinePreScreeningState>((ref) {
  return BookVaccinePreScreeningController();
});
