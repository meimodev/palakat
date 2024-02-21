class SelfCheckinConsultationPrescriptionState {
  final bool? selectAllMedicine;

  const SelfCheckinConsultationPrescriptionState({this.selectAllMedicine});

  SelfCheckinConsultationPrescriptionState copyWith(
      {final bool? selectAllMedicine}) {
    return SelfCheckinConsultationPrescriptionState(
      selectAllMedicine: selectAllMedicine ?? this.selectAllMedicine,
    );
  }
}
