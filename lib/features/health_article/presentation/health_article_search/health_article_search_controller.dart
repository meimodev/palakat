import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/health_article/presentation/health_article_search/health_article_search_state.dart';

class HealthArticleSearchController
    extends StateNotifier<HealthArticleSearchState> {
  HealthArticleSearchController() : super(const HealthArticleSearchState()) {
    // DO SOMETHING
  }

  final textController = TextEditingController();

  setSearchValue(String? text) {
    state = state.copyWith(searchValue: text);
  }
}

final HealthArticleSearchControllerProvider = StateNotifierProvider<
    HealthArticleSearchController, HealthArticleSearchState>((ref) {
  return HealthArticleSearchController();
});
