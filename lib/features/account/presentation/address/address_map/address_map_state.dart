import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halo_hermina/core/constants/constants.dart';

class AddressMapState {
  final FormType type;
  final bool isLoading;
  final String? addressLabel;
  final String? address;
  final double? latitude;
  final double? longitude;
  final Set<Marker> markers;

  const AddressMapState({
    this.type = FormType.add,
    this.isLoading = true,
    this.addressLabel,
    this.address,
    this.latitude,
    this.longitude,
    this.markers = const {},
  });

  AddressMapState copyWith({
    FormType? type,
    bool? isLoading,
    String? addressLabel,
    String? address,
    double? latitude,
    double? longitude,
    Set<Marker>? markers,
  }) {
    return AddressMapState(
      type: type ?? this.type,
      isLoading: isLoading ?? this.isLoading,
      addressLabel: addressLabel ?? this.addressLabel,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      markers: markers ?? this.markers,
    );
  }
}
