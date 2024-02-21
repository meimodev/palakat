class BookLaboratoryChooseScheduleState {
  final String selectedHospital;

  const BookLaboratoryChooseScheduleState({required this.selectedHospital});

  BookLaboratoryChooseScheduleState copyWith({final String? selectedHospital}) {
    return BookLaboratoryChooseScheduleState(
      selectedHospital: selectedHospital ?? this.selectedHospital,
    );
  }
}
