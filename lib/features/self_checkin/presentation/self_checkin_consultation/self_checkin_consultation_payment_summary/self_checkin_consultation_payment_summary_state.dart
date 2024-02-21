import 'package:halo_hermina/core/constants/enums/pickup_method_enum.dart';

class SelfCheckInConsultationPaymentSummaryState {
  final PickUpDeliveryOptionEnum? selectedOption;
  final String? selectedAddress;
  final String? selectedName;
  final String? pickupMethod;
  final List<Map<String, dynamic>>? otherServices;

  const SelfCheckInConsultationPaymentSummaryState({
    this.selectedOption,
    this.selectedAddress,
    this.selectedName,
    this.pickupMethod,
    this.otherServices,
  });

  SelfCheckInConsultationPaymentSummaryState copyWith({
    final PickUpDeliveryOptionEnum? Function()? selectedOption,
    final String? selectedAddress,
    final String? selectedName,
    final String? pickupMethod,
    final List<Map<String, dynamic>>? otherServices,
  }) {
    return SelfCheckInConsultationPaymentSummaryState(
      selectedOption:
          selectedOption != null ? selectedOption() : this.selectedOption,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedName: selectedName ?? this.selectedName,
      pickupMethod: pickupMethod ?? this.pickupMethod,
      otherServices: otherServices ?? otherServices,
    );
  }
}
