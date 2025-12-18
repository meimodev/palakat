import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'articles_list_state.freezed.dart';

@freezed
abstract class ArticlesListState with _$ArticlesListState {
  const ArticlesListState._();

  const factory ArticlesListState({
    @Default(true) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(<Article>[]) List<Article> articles,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool hasMorePages,
    String? search,
    ArticleType? filterType,
    String? errorMessage,
  }) = _ArticlesListState;

  bool get hasActiveFilters {
    final hasSearch = (search != null && search!.trim().isNotEmpty);
    return hasSearch || filterType != null;
  }
}
