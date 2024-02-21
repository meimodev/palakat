import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookLaboratoryPreScreeningController
    extends StateNotifier<BookLaboratoryPreScreeningState> {
  BookLaboratoryPreScreeningController()
      : super(BookLaboratoryPreScreeningState(isEligible: false));

  void changeEligibility(bool isEligible) {
    state = state.copyWith(isEligible: isEligible);
  }
}

final bookLaboratoryPreScreeningProvider = StateNotifierProvider.autoDispose<
    BookLaboratoryPreScreeningController,
    BookLaboratoryPreScreeningState>((ref) {
  return BookLaboratoryPreScreeningController();
});
