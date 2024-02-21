import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookVaccinePaymentMethodController
    extends StateNotifier<BookVaccinePaymentMethodState> {
  BookVaccinePaymentMethodController()
      : super(
          const BookVaccinePaymentMethodState(
            selectedPaymentMethod: PaymentMethod.cashier,
            total: 123000,
            serviceFee: 0,
          ),
        );

  void onChangedPaymentMethod(PaymentMethod value) {
    setSelectedPayment(value);
  }

  void setSelectedPayment(PaymentMethod value) {
    final int serviceFee = value != PaymentMethod.cashier ? 4500 : 0;
    state = state.copyWith(
      selectedPaymentMethod: value,
      serviceFee: serviceFee,
    );
  }
}

final bookVaccinePaymentMethodControllerProvider =
    StateNotifierProvider.autoDispose<BookVaccinePaymentMethodController,
        BookVaccinePaymentMethodState>((ref) {
  return BookVaccinePaymentMethodController();
});
