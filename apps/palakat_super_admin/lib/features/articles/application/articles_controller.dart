import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';

import '../data/article_model.dart';
import '../data/articles_repository.dart';

final articlesControllerProvider =
    NotifierProvider<ArticlesController, ArticlesState>(ArticlesController.new);

class ArticlesState {
  const ArticlesState({
    this.items = const AsyncValue.loading(),
    this.page = 1,
    this.pageSize = 10,
    this.search = '',
    this.type,
    this.status,
  });

  final AsyncValue<PaginationResponseWrapper<ArticleModel>> items;
  final int page;
  final int pageSize;
  final String search;
  final String? type;
  final String? status;

  ArticlesState copyWith({
    AsyncValue<PaginationResponseWrapper<ArticleModel>>? items,
    int? page,
    int? pageSize,
    String? search,
    String? type,
    String? status,
  }) {
    return ArticlesState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}

class ArticlesController extends Notifier<ArticlesState> {
  late final ArticlesRepository _repository;

  @override
  ArticlesState build() {
    _repository = ref.read(articlesRepositoryProvider);
    Future.microtask(() => refresh());
    return const ArticlesState();
  }

  Future<void> refresh() async {
    state = state.copyWith(items: const AsyncValue.loading());
    try {
      final res = await _repository.fetchArticles(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
        type: state.type,
        status: state.status,
        sortBy: 'updatedAt',
        sortOrder: 'desc',
      );
      state = state.copyWith(items: AsyncValue.data(res));
    } catch (e, st) {
      state = state.copyWith(items: AsyncValue.error(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(search: value, page: 1);
    Future.microtask(() => refresh());
  }

  void onChangedStatus(String? value) {
    state = state.copyWith(status: value, page: 1);
    Future.microtask(() => refresh());
  }

  void onChangedType(String? value) {
    state = state.copyWith(type: value, page: 1);
    Future.microtask(() => refresh());
  }

  void onChangedPageSize(int value) {
    state = state.copyWith(pageSize: value, page: 1);
    Future.microtask(() => refresh());
  }

  void onChangedPage(int value) {
    state = state.copyWith(page: value);
    Future.microtask(() => refresh());
  }

  void onPrev() {
    if (state.page > 1) {
      state = state.copyWith(page: state.page - 1);
      Future.microtask(() => refresh());
    }
  }

  void onNext() {
    final pagination = state.items.asData?.value.pagination;
    if (pagination != null && pagination.hasNext) {
      state = state.copyWith(page: state.page + 1);
      Future.microtask(() => refresh());
    }
  }
}
