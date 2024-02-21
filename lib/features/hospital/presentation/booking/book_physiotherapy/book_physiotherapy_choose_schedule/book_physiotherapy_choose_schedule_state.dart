class BookPhysiotherapyChooseScheduleState {
  final String selectedHospital;

  const BookPhysiotherapyChooseScheduleState({required this.selectedHospital});

  BookPhysiotherapyChooseScheduleState copyWith({final String? selectedHospital}) {
    return BookPhysiotherapyChooseScheduleState(
      selectedHospital: selectedHospital ?? this.selectedHospital,
    );
  }
}
