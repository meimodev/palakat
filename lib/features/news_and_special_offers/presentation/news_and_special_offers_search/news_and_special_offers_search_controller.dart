import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/news_and_special_offers/presentation/news_and_special_offers_search/news_and_special_offers_search_state.dart';

class NewsAndSpecialOffersSearchController
    extends StateNotifier<NewsAndSpecialOffersSearchState> {
  NewsAndSpecialOffersSearchController()
      : super(const NewsAndSpecialOffersSearchState()) {
    // DO SOMETHING
  }

  final textController = TextEditingController();

  setSearchValue(String? text) {
    state = state.copyWith(searchValue: text);
  }
}

final newsAndSpecialOffersSearchControllerProvider = StateNotifierProvider<
    NewsAndSpecialOffersSearchController,
    NewsAndSpecialOffersSearchState>((ref) {
  return NewsAndSpecialOffersSearchController();
});
