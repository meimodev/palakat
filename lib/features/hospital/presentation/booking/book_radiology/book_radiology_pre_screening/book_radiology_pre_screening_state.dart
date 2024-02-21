
class BookRadiologyPreScreeningState {
  bool isEligible;

  BookRadiologyPreScreeningState({required this.isEligible});

  BookRadiologyPreScreeningState copyWith({bool? isEligible}) =>
      BookRadiologyPreScreeningState(isEligible: isEligible ?? this.isEligible);
}
