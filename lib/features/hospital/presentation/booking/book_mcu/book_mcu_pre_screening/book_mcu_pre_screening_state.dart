class BookMcuPreScreeningState {
  bool isEligible;

  BookMcuPreScreeningState({required this.isEligible});

  BookMcuPreScreeningState copyWith({bool? isEligible}) =>
      BookMcuPreScreeningState(isEligible: isEligible ?? this.isEligible);
}
