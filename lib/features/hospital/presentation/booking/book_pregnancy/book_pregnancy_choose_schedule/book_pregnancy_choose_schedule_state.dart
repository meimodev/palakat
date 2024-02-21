class BookPregnancyChooseScheduleState {
  final String selectedHospital;

  const BookPregnancyChooseScheduleState({required this.selectedHospital});

  BookPregnancyChooseScheduleState copyWith({final String? selectedHospital}) {
    return BookPregnancyChooseScheduleState(
      selectedHospital: selectedHospital ?? this.selectedHospital,
    );
  }
}
