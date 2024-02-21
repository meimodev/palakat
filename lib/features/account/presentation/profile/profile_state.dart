import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';

class ProfileState {
  final bool isLoading;
  final AsyncValue<bool?> valid;
  final String? selectedGender;
  final DateTime? selectedDate;
  final DateTime? savedDate;
  final Map<String, dynamic> errors;
  final IdentityType? selectedIdentity;

  const ProfileState({
    this.isLoading = true,
    this.valid = const AsyncData(null),
    this.selectedGender,
    this.selectedDate,
    this.savedDate,
    this.errors = const {},
    this.selectedIdentity,
  });

  ProfileState copyWith({
    bool? isLoading,
    AsyncValue<bool?>? valid,
    String? selectedGender,
    DateTime? selectedDate,
    DateTime? savedDate,
    Map<String, dynamic>? errors,
    IdentityType? selectedIdentity,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      valid: valid ?? this.valid,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedDate: selectedDate ?? this.selectedDate,
      savedDate: savedDate ?? this.savedDate,
      errors: errors ?? this.errors,
      selectedIdentity: selectedIdentity ?? this.selectedIdentity,
    );
  }
}
