import 'package:halo_hermina/core/constants/constants.dart';

class SelfCheckInConsultationPaymentMethodState {
  final PaymentMethod selectedPaymentMethod;
  final int total;
  final int serviceFee;

  const SelfCheckInConsultationPaymentMethodState(
      {required this.total,
      required this.serviceFee,
      required this.selectedPaymentMethod,});

  SelfCheckInConsultationPaymentMethodState copyWith({
    PaymentMethod? selectedPaymentMethod,
    int? total,
    int? serviceFee,
  }) {
    return SelfCheckInConsultationPaymentMethodState(
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      total: total ?? this.total,
      serviceFee: serviceFee ?? this.serviceFee,
    );
  }
}
