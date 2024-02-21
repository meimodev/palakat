import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookRadiologyPreScreeningController extends StateNotifier<BookRadiologyPreScreeningState> {
  BookRadiologyPreScreeningController() : super(BookRadiologyPreScreeningState(isEligible: false));

  void changeEligibility(bool isEligible) {
    state = state.copyWith(isEligible: isEligible);
  }
}

final bookRadiologyPreScreeningProvider = StateNotifierProvider.autoDispose<
    BookRadiologyPreScreeningController, BookRadiologyPreScreeningState>((ref) {
  return BookRadiologyPreScreeningController();
});
