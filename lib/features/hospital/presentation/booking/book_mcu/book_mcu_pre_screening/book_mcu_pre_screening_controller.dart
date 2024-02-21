import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookMcuPreScreeningController
    extends StateNotifier<BookMcuPreScreeningState> {
  BookMcuPreScreeningController()
      : super(BookMcuPreScreeningState(isEligible: false));

  void changeEligibility(bool isEligible) {
    state = state.copyWith(isEligible: isEligible);
  }
}

final bookMcuPreScreeningProvider = StateNotifierProvider.autoDispose<
    BookMcuPreScreeningController, BookMcuPreScreeningState>((ref) {
  return BookMcuPreScreeningController();
});
