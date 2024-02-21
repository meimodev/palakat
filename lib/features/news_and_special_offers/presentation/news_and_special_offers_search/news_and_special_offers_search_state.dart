class NewsAndSpecialOffersSearchState {
  final String? searchValue;

  const NewsAndSpecialOffersSearchState({this.searchValue});

  NewsAndSpecialOffersSearchState copyWith({String? searchValue}) {
    return NewsAndSpecialOffersSearchState(
        searchValue: searchValue ?? this.searchValue);
  }
}
