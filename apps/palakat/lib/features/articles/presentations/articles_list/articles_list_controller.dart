import 'package:palakat/features/articles/presentations/articles_list/articles_list_state.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'articles_list_controller.g.dart';

@riverpod
class ArticlesListController extends _$ArticlesListController {
  static const int _pageSize = 10;

  ArticleRepository get _articleRepository =>
      ref.read(articleRepositoryProvider);

  @override
  ArticlesListState build() {
    Future.microtask(() => fetchArticles(refresh: true));
    return const ArticlesListState();
  }

  PaginationRequestWrapper<GetFetchArticlesRequest> _buildRequest({
    required int page,
  }) {
    return PaginationRequestWrapper(
      page: page,
      pageSize: _pageSize,
      sortBy: 'publishedAt',
      sortOrder: 'desc',
      data: GetFetchArticlesRequest(
        search: state.search,
        type: state.filterType,
      ),
    );
  }

  Future<void> fetchArticles({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        articles: [],
        currentPage: 1,
        totalPages: 1,
        hasMorePages: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final result = await _articleRepository.fetchArticles(
      paginationRequest: _buildRequest(page: 1),
    );

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          isLoading: false,
          articles: response.data,
          currentPage: response.pagination.page,
          totalPages: response.pagination.totalPages,
          hasMorePages: response.pagination.hasNext,
          errorMessage: null,
        );
      },
      onFailure: (failure) {
        if (failure.code == 401 || failure.message.trim().isEmpty) {
          state = state.copyWith(isLoading: false, errorMessage: null);
          return;
        }
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;

    final result = await _articleRepository.fetchArticles(
      paginationRequest: _buildRequest(page: nextPage),
    );

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          isLoadingMore: false,
          articles: [...state.articles, ...response.data],
          currentPage: response.pagination.page,
          totalPages: response.pagination.totalPages,
          hasMorePages: response.pagination.hasNext,
        );
      },
      onFailure: (_) {
        state = state.copyWith(isLoadingMore: false);
      },
    );
  }

  void setSearch(String? value) {
    final query = value?.trim();
    state = state.copyWith(search: query, errorMessage: null);
    fetchArticles(refresh: true);
  }

  void setTypeFilter(ArticleType? type) {
    state = state.copyWith(filterType: type, errorMessage: null);
    fetchArticles(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(search: null, filterType: null, errorMessage: null);
    fetchArticles(refresh: true);
  }
}
