import 'package:palakat_shared/core/models/article.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/models/response/response.dart';
import 'package:palakat_shared/core/services/socket_service.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_repository.g.dart';

@riverpod
ArticleRepository articleRepository(Ref ref) => ArticleRepository(ref);

class ArticleRepository {
  ArticleRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Article>, Failure>> fetchArticles({
    required PaginationRequestWrapper<GetFetchArticlesRequest>
    paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      final queryKey = query.toString();

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('articles.list', query);

      // Save to offline cache on success (page 1 only)
      if (paginationRequest.page == 1) {
        try {
          await _ref
              .read(localStorageServiceProvider)
              .saveArticlesCache(queryKey, data);
        } catch (_) {}
      }

      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Article.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      // Attempt to load from offline cache on failure (page 1 only)
      if (paginationRequest.page == 1) {
        try {
          final query = paginationRequest.toJsonFlat((p) => p.toJson());
          final queryKey = query.toString();
          final cache = _ref
              .read(localStorageServiceProvider)
              .getArticlesCache(queryKey);
          if (cache != null) {
            final result = PaginationResponseWrapper.fromJson(
              cache,
              (e) => Article.fromJson(e as Map<String, dynamic>),
            );
            return Result.success(result);
          }
        } catch (_) {}
      }
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Article, Failure>> fetchArticle({
    required int articleId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('articles.get', {'id': articleId});

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid article response payload'));
      }
      return Result.success(Article.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ArticleLikeResult, Failure>> like({
    required int articleId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('articles.like', {'id': articleId});

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid like response payload'));
      }
      return Result.success(ArticleLikeResult.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ArticleLikeResult, Failure>> unlike({
    required int articleId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('articles.unlike', {'id': articleId});

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid unlike response payload'));
      }
      return Result.success(ArticleLikeResult.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
