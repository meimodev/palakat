import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/presentation.dart';

class SelfCheckInConsultationPaymentMethodController
    extends StateNotifier<SelfCheckInConsultationPaymentMethodState> {
  SelfCheckInConsultationPaymentMethodController()
      : super(
          const SelfCheckInConsultationPaymentMethodState(
            selectedPaymentMethod: PaymentMethod.cashier,
            total: 117000,
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

final selfCheckInConsultationPaymentMethodControllerProvider =
    StateNotifierProvider.autoDispose<
        SelfCheckInConsultationPaymentMethodController,
        SelfCheckInConsultationPaymentMethodState>((ref) {
  return SelfCheckInConsultationPaymentMethodController();
});

// enum FoodMenuSegment { patient, companion }
