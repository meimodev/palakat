import 'package:halo_hermina/core/constants/enums/enums.dart';
import 'package:halo_hermina/features/domain.dart';

class SelfCheckInPickUpMethodsState {
  final PickUpDeliveryOptionEnum selectedMethod;
  final String selectedLocation;
  final UserAddress? selectedAddress;

  SelfCheckInPickUpMethodsState({
    this.selectedMethod = PickUpDeliveryOptionEnum.pickup,
    this.selectedLocation = '',
    this.selectedAddress,
  });

  SelfCheckInPickUpMethodsState copyWith({
    PickUpDeliveryOptionEnum? selectedMethod,
    String? selectedLocation,
    UserAddress? Function()? selectedAddress,
  }) =>
      SelfCheckInPickUpMethodsState(
        selectedMethod: selectedMethod ?? this.selectedMethod,
        selectedLocation: selectedLocation ?? this.selectedLocation,
        selectedAddress: selectedAddress != null ? selectedAddress() : this.selectedAddress,
      );
}
