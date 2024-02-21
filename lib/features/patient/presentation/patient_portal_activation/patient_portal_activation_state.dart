import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/domain.dart';

class PatientPortalActivationState {
  final bool loading;
  final bool canProceed;
  final bool tncAccept;
  final Map<String, dynamic> errors;
  final MediaUpload? selectedPhoto;
  final MediaUpload? selectedPhotoWithIdentityCard;
  final String genderSerial;
  final IdentityType selectedIdentity;

  const PatientPortalActivationState({
    this.canProceed = false,
    this.tncAccept = false,
    this.selectedPhoto,
    this.selectedPhotoWithIdentityCard,
    this.errors = const {},
    this.genderSerial = "",
    this.selectedIdentity = IdentityType.ktp,
    this.loading = false,
  });

  PatientPortalActivationState copyWith({
    bool? canProceed,
    bool? tncAccept,
    MediaUpload? selectedPhoto,
    MediaUpload? selectedPhotoWithIdentityCard,
    String? genderSerial,
    IdentityType? selectedIdentity,
    bool? loading,
  }) {
    return PatientPortalActivationState(
      canProceed: canProceed ?? this.canProceed,
      tncAccept: tncAccept ?? this.tncAccept,
      selectedPhoto: selectedPhoto ?? this.selectedPhoto,
      selectedPhotoWithIdentityCard:
          selectedPhotoWithIdentityCard ?? this.selectedPhotoWithIdentityCard,
      genderSerial: genderSerial ?? this.genderSerial,
      selectedIdentity: selectedIdentity ?? this.selectedIdentity,
      loading: loading ?? this.loading,
    );
  }
}
