import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/account/domain/user_address.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/core/constants/enums/pickup_method_enum.dart';

class SelfCheckInPickUpMethodsController
    extends StateNotifier<SelfCheckInPickUpMethodsState> {
  SelfCheckInPickUpMethodsController() : super(SelfCheckInPickUpMethodsState());

  void setSelectedMethod(PickUpDeliveryOptionEnum value) {
    state = state.copyWith(
      selectedMethod: value,
    );
    if (value == PickUpDeliveryOptionEnum.pickup) {
      state = state.copyWith(selectedAddress: () => null);
    }
    if (value == PickUpDeliveryOptionEnum.delivery) {
      state = state.copyWith(selectedLocation: '');
    }
  }

  void setSelectedLocation(String location) {
    state = state.copyWith(selectedLocation: location);
  }

  void setSelectedAddress(UserAddress? address) {
    state = state.copyWith(selectedAddress: () => address);
  }
}

final selfCheckInPickUpMethodsController = StateNotifierProvider.autoDispose<
    SelfCheckInPickUpMethodsController, SelfCheckInPickUpMethodsState>((
  ref,
) {
  return SelfCheckInPickUpMethodsController();
});
