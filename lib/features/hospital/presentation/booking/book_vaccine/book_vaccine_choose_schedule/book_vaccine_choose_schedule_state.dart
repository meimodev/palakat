class BookVaccineChooseScheduleState {
  final String selectedHospital;
  final String selectedDoctor;
  final String? searchValue;

  const BookVaccineChooseScheduleState({
    required this.selectedDoctor,
    required this.selectedHospital,
    this.searchValue,
  });

  BookVaccineChooseScheduleState copyWith(
      {String? searchValue,
      final String? selectedHospital,
      final String? selectedDoctor}) {
    return BookVaccineChooseScheduleState(
      searchValue: searchValue ?? this.searchValue,
      selectedHospital: selectedHospital ?? this.selectedHospital,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
    );
  }
}
