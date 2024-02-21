import 'package:halo_hermina/features/domain.dart';

class AddressListState {
  final AddressListType type;
  final bool isLoading;
  final List<UserAddress> userAddresses;
  final String? selectedAddress;
  final String? selectedName;
  final String? selectedAddressDesc;

  const AddressListState({
    this.type = AddressListType.basic,
    this.isLoading = false,
    this.selectedAddress,
    this.selectedName,
    this.selectedAddressDesc,
    this.userAddresses = const [],
  });

  AddressListState copyWith({
    AddressListType? type,
    bool? isLoading,
    String? selectedAddress,
    String? selectedName,
    String? selectedAddressDesc,
    List<UserAddress>? userAddresses,
  }) {
    return AddressListState(
      type: type ?? this.type,
      isLoading: isLoading ?? this.isLoading,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedName: selectedName ?? this.selectedName,
      selectedAddressDesc: selectedAddressDesc ?? this.selectedAddressDesc,
      userAddresses: userAddresses ?? this.userAddresses,
    );
  }
}
