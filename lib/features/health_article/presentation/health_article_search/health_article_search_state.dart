class HealthArticleSearchState {
  final String? searchValue;

  const HealthArticleSearchState({this.searchValue});

  HealthArticleSearchState copyWith({String? searchValue}) {
    return HealthArticleSearchState(
        searchValue: searchValue ?? this.searchValue);
  }
}
