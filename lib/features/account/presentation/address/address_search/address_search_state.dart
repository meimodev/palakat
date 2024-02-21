import 'package:halo_hermina/features/domain.dart';

class AddressSearchState {
  final AddressSearchType type;
  final bool onGeocodingAddress;
  final List<AutocompleteAddress> address;

  const AddressSearchState({
    this.type = AddressSearchType.add,
    this.address = const [],
    this.onGeocodingAddress = false,
  });

  AddressSearchState copyWith({
    AddressSearchType? type,
    List<AutocompleteAddress>? address,
    bool? onGeocodingAddress,
  }) {
    return AddressSearchState(
      type: type ?? this.type,
      address: address ?? this.address,
      onGeocodingAddress: onGeocodingAddress ?? this.onGeocodingAddress,
    );
  }
}
