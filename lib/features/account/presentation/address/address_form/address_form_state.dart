import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';

class AddressFormState {
  final FormType formType;
  final String? serial;
  final AsyncValue<bool?> valid;
  final double longitude;
  final double latitude;
  final String? pinpointAddressLabel;
  final String? pinpointAddress;
  final bool isPrimary;
  final bool isLoading;
  final Map<String, dynamic> errors;

  const AddressFormState({
    this.formType = FormType.add,
    this.serial,
    this.valid = const AsyncData(null),
    this.isPrimary = false,
    this.isLoading = false,
    this.latitude = 0,
    this.longitude = 0,
    this.pinpointAddressLabel,
    this.pinpointAddress,
    this.errors = const {},
  });

  AddressFormState copyWith({
    FormType? formType,
    String? serial,
    AsyncValue<bool?>? valid,
    bool? isPrimary,
    bool? isLoading,
    double? latitude,
    double? longitude,
    String? pinpointAddressLabel,
    String? pinpointAddress,
    Map<String, dynamic>? errors,
  }) {
    return AddressFormState(
      formType: formType ?? this.formType,
      serial: serial ?? this.serial,
      valid: valid ?? this.valid,
      isPrimary: isPrimary ?? this.isPrimary,
      isLoading: isLoading ?? this.isLoading,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pinpointAddressLabel: pinpointAddressLabel ?? this.pinpointAddressLabel,
      pinpointAddress: pinpointAddress ?? this.pinpointAddress,
      errors: errors ?? this.errors,
    );
  }
}
