import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';
import 'package:palakat_shared/core/services/socket_service.dart';

import '../../auth/application/super_admin_auth_controller.dart';
import 'article_model.dart';

final articlesRepositoryProvider = Provider<ArticlesRepository>((ref) {
  final socket = ref.watch(superAdminSocketServiceProvider);
  return ArticlesRepository(socket: socket);
});

class ArticlesRepository {
  ArticlesRepository({required this.socket});

  final SocketService socket;

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

    final data = await socket.rpc('admin.articles.list', query);
    return PaginationResponseWrapper.fromJson(
      data,
      (e) => ArticleModel.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<ArticleModel> fetchArticle(int id) async {
    final body = await socket.rpc('admin.articles.get', {'id': id});
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

    final body = await socket.rpc('admin.articles.create', payload);
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

    final body = await socket.rpc('admin.articles.update', {
      'id': id,
      'dto': payload,
    });
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return ArticleModel.fromJson(data);
  }

  Future<void> publish(int id) async {
    await socket.rpc('admin.articles.publish', {'id': id});
  }

  Future<void> unpublish(int id) async {
    await socket.rpc('admin.articles.unpublish', {'id': id});
  }

  Future<void> archive(int id) async {
    await socket.rpc('admin.articles.archive', {'id': id});
  }

  Future<ArticleModel> uploadCover({
    required int id,
    required List<int> bytes,
    required String filename,
    String? contentType,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final init = await socket.rpc('admin.articles.cover.upload.init', {
      'id': id,
      'sizeBytes': bytes.length,
      'contentType': contentType ?? 'image/png',
      'originalName': filename,
    });

    final initData = init['data'];
    if (initData is! Map) throw StateError('Invalid upload init response');
    final uploadId = initData['uploadId'];
    final chunkSize = initData['chunkSize'];
    if (uploadId is! String || uploadId.isEmpty) {
      throw StateError('Invalid upload id');
    }
    final cs = chunkSize is int ? chunkSize : (256 * 1024);

    int sent = 0;
    try {
      while (sent < bytes.length) {
        final end = (sent + cs) > bytes.length ? bytes.length : (sent + cs);
        final chunk = bytes.sublist(sent, end);
        final b64 = base64Encode(chunk);
        await socket.rpc('admin.articles.cover.upload.chunk', {
          'uploadId': uploadId,
          'dataBase64': b64,
        });
        sent = end;
        onProgress?.call(sent, bytes.length);
      }

      final done = await socket.rpc('admin.articles.cover.upload.complete', {
        'uploadId': uploadId,
      });
      final data = done['data'];
      if (data is! Map<String, dynamic>) throw StateError('Invalid response');
      return ArticleModel.fromJson(data);
    } catch (e) {
      try {
        await socket.rpc('admin.articles.cover.upload.abort', {
          'uploadId': uploadId,
        });
      } catch (_) {}
      rethrow;
    }
  }
}
