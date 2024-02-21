
class BookRadiologyChooseScheduleState {
  final String selectedHospital;

  const BookRadiologyChooseScheduleState({required this.selectedHospital});

  BookRadiologyChooseScheduleState copyWith({final String? selectedHospital}) {
    return BookRadiologyChooseScheduleState(
      selectedHospital: selectedHospital ?? this.selectedHospital,
    );
  }
}
