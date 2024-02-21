class BookLaboratoryPreScreeningState {
  bool isEligible;

  BookLaboratoryPreScreeningState({required this.isEligible});

  BookLaboratoryPreScreeningState copyWith({bool? isEligible}) =>
      BookLaboratoryPreScreeningState(
          isEligible: isEligible ?? this.isEligible);
}
