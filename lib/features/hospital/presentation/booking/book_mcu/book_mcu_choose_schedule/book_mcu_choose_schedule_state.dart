class BookMcuChooseScheduleState {
  final String selectedHospital;

  const BookMcuChooseScheduleState({required this.selectedHospital});

  BookMcuChooseScheduleState copyWith({final String? selectedHospital}) {
    return BookMcuChooseScheduleState(
      selectedHospital: selectedHospital ?? this.selectedHospital,
    );
  }
}
