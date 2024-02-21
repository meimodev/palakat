class BookVaccinePreScreeningState {
  bool isEligible;

  BookVaccinePreScreeningState({required this.isEligible});

  BookVaccinePreScreeningState copyWith({bool? isEligible}) =>
      BookVaccinePreScreeningState(isEligible: isEligible ?? this.isEligible);
}
