import 'package:halo_hermina/core/constants/constants.dart';

class BookVaccinePaymentMethodState {
  final PaymentMethod selectedPaymentMethod;
  final int total;
  final int serviceFee;

  const BookVaccinePaymentMethodState({
    required this.total,
    required this.serviceFee,
    required this.selectedPaymentMethod,
  });

  BookVaccinePaymentMethodState copyWith({
    PaymentMethod? selectedPaymentMethod,
    int? total,
    int? serviceFee,
  }) {
    return BookVaccinePaymentMethodState(
      selectedPaymentMethod:
      selectedPaymentMethod ?? this.selectedPaymentMethod,
      total: total ?? this.total,
      serviceFee: serviceFee ?? this.serviceFee,
    );
  }
}
