import 'package:palakat/features/articles/presentations/article_detail/article_detail_state.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_detail_controller.g.dart';

@riverpod
class ArticleDetailController extends _$ArticleDetailController {
  ArticleRepository get _articleRepository =>
      ref.read(articleRepositoryProvider);

  @override
  ArticleDetailState build(int articleId) {
    Future.microtask(() => fetchArticle());
    return const ArticleDetailState();
  }

  Future<void> fetchArticle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _articleRepository.fetchArticle(articleId: articleId);

    result.when(
      onSuccess: (article) {
        state = state.copyWith(isLoading: false, article: article);
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

  Future<void> toggleLike() async {
    if (state.isLikeLoading) return;
    if (state.article?.id == null) return;

    state = state.copyWith(isLikeLoading: true);

    final currentLiked = state.liked ?? false;

    final result = currentLiked
        ? await _articleRepository.unlike(articleId: articleId)
        : await _articleRepository.like(articleId: articleId);

    result.when(
      onSuccess: (likeResult) {
        final article = state.article;
        if (article == null) {
          state = state.copyWith(isLikeLoading: false, liked: likeResult.liked);
          return;
        }

        state = state.copyWith(
          isLikeLoading: false,
          liked: likeResult.liked,
          article: article.copyWith(likesCount: likeResult.likesCount),
        );
      },
      onFailure: (failure) {
        if (failure.code == 401 || failure.message.trim().isEmpty) {
          state = state.copyWith(isLikeLoading: false, errorMessage: null);
          return;
        }
        state = state.copyWith(
          isLikeLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
