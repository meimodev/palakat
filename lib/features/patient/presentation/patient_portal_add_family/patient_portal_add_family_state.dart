class PatientPortalAddFamilyState {
  final bool canProceed;
  final bool tncAccept;
  final String idCardBase64;
  final String idCardAndPhotoBase64;
  final String? gender;

  const PatientPortalAddFamilyState({
    this.canProceed = false,
    this.idCardBase64 = "",
    this.idCardAndPhotoBase64 = "",
    this.tncAccept = false,
    this.gender,
  });

  PatientPortalAddFamilyState copyWith({
    bool? canProceed,
    String? idCardAndPhotoBase64,
    String? idCardBase64,
    bool? tncAccept,
    String? gender,
  }) {
    return PatientPortalAddFamilyState(
      canProceed: canProceed ?? this.canProceed,
      idCardAndPhotoBase64: idCardAndPhotoBase64 ?? this.idCardAndPhotoBase64,
      idCardBase64: idCardBase64 ?? this.idCardBase64,
      tncAccept: tncAccept ?? this.tncAccept,
      gender: gender ?? this.gender,
    );
  }
}
