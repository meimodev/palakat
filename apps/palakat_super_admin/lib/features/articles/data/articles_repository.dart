import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';

import '../../auth/application/super_admin_auth_controller.dart';
import 'article_model.dart';

final articlesRepositoryProvider = Provider<ArticlesRepository>((ref) {
  final dio = ref.watch(superAdminAuthedDioProvider);
  return ArticlesRepository(dio: dio);
});

class ArticlesRepository {
  ArticlesRepository({required this.dio});

  final Dio dio;

  static const Object _notProvided = Object();

  Future<PaginationResponseWrapper<ArticleModel>> fetchArticles({
    required int page,
    required int pageSize,
    String? search,
    String? type,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (sortBy != null && sortBy.trim().isNotEmpty) 'sortBy': sortBy.trim(),
      if (sortOrder != null && sortOrder.trim().isNotEmpty)
        'sortOrder': sortOrder.trim(),
    };

    final res = await dio.get<Map<String, dynamic>>(
      'admin/articles',
      queryParameters: query,
    );

    final data = res.data ?? const {};
    return PaginationResponseWrapper.fromJson(
      data,
      (e) => ArticleModel.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<ArticleModel> fetchArticle(int id) async {
    final res = await dio.get<Map<String, dynamic>>('admin/articles/$id');
    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Invalid response');
    }
    return ArticleModel.fromJson(data);
  }

  Future<ArticleModel> create({
    required String type,
    required String title,
    String? slug,
    String? excerpt,
    required String content,
    String? coverImageUrl,
  }) async {
    final payload = <String, dynamic>{
      'type': type,
      'title': title,
      'content': content,
      if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
      if (excerpt != null && excerpt.trim().isNotEmpty)
        'excerpt': excerpt.trim(),
      if (coverImageUrl != null && coverImageUrl.trim().isNotEmpty)
        'coverImageUrl': coverImageUrl.trim(),
    };

    final res = await dio.post<Map<String, dynamic>>(
      'admin/articles',
      data: payload,
    );
    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return ArticleModel.fromJson(data);
  }

  Future<ArticleModel> update({
    required int id,
    String? type,
    String? title,
    String? slug,
    Object? excerpt = _notProvided,
    String? content,
    Object? coverImageUrl = _notProvided,
  }) async {
    final payload = <String, dynamic>{
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (slug != null) 'slug': slug,
      if (excerpt != _notProvided) 'excerpt': excerpt,
      if (content != null) 'content': content,
      if (coverImageUrl != _notProvided) 'coverImageUrl': coverImageUrl,
    };

    final res = await dio.patch<Map<String, dynamic>>(
      'admin/articles/$id',
      data: payload,
    );
    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return ArticleModel.fromJson(data);
  }

  Future<void> publish(int id) async {
    await dio.post('admin/articles/$id/publish');
  }

  Future<void> unpublish(int id) async {
    await dio.post('admin/articles/$id/unpublish');
  }

  Future<void> archive(int id) async {
    await dio.delete('admin/articles/$id');
  }

  Future<ArticleModel> uploadCover({
    required int id,
    required List<int> bytes,
    required String filename,
    String? contentType,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: contentType == null ? null : MediaType.parse(contentType),
      ),
    });

    final res = await dio.post<Map<String, dynamic>>(
      'admin/articles/$id/cover',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return ArticleModel.fromJson(data);
  }
}
