import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/article.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/models/response/response.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/services/http_service.dart';
import 'package:palakat_shared/core/utils/error_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';

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
      final http = _ref.read(httpServiceProvider);
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.articles,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Article.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final handled = Failure.fromException(e);
      if (handled.code == 401 && handled.message.trim().isEmpty) {
        return Result.failure(handled);
      }
      final error = ErrorMapper.fromDio(e, 'Failed to fetch articles');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch articles', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Article, Failure>> fetchArticle({
    required int articleId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.article(articleId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid article response payload'));
      }
      return Result.success(Article.fromJson(json));
    } on DioException catch (e) {
      final handled = Failure.fromException(e);
      if (handled.code == 401 && handled.message.trim().isEmpty) {
        return Result.failure(handled);
      }
      final error = ErrorMapper.fromDio(e, 'Failed to fetch article');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch article', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<ArticleLikeResult, Failure>> like({
    required int articleId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.articleLike(articleId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid like response payload'));
      }
      return Result.success(ArticleLikeResult.fromJson(json));
    } on DioException catch (e) {
      final handled = Failure.fromException(e);
      if (handled.code == 401 && handled.message.trim().isEmpty) {
        return Result.failure(handled);
      }
      final error = ErrorMapper.fromDio(e, 'Failed to like article');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to like article', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<ArticleLikeResult, Failure>> unlike({
    required int articleId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.delete<Map<String, dynamic>>(
        Endpoints.articleLike(articleId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid unlike response payload'));
      }
      return Result.success(ArticleLikeResult.fromJson(json));
    } on DioException catch (e) {
      final handled = Failure.fromException(e);
      if (handled.code == 401 && handled.message.trim().isEmpty) {
        return Result.failure(handled);
      }
      final error = ErrorMapper.fromDio(e, 'Failed to unlike article');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to unlike article', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
