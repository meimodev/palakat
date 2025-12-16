import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/file_manager.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';

part 'file_manager_repository.g.dart';

@riverpod
FileManagerRepository fileManagerRepository(Ref ref) =>
    FileManagerRepository(ref);

class FileManagerRepository {
  FileManagerRepository(this._ref);

  final Ref _ref;

  Future<Result<FileManager, Failure>> finalize({
    required int churchId,
    required String path,
    required double sizeInKB,
    String? bucket,
    String? contentType,
    String? originalName,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.fileFinalize,
        data: {
          'churchId': churchId,
          if (bucket != null) 'bucket': bucket,
          'path': path,
          'sizeInKB': sizeInKB,
          if (contentType != null) 'contentType': contentType,
          if (originalName != null) 'originalName': originalName,
        },
      );

      final body = response.data ?? const {};
      final json = body['data'];
      if (json is! Map<String, dynamic>) {
        return Result.failure(
          Failure('Invalid finalize file response payload'),
        );
      }
      return Result.success(FileManager.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to finalize file');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to finalize file', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<String, Failure>> resolveDownloadUrl({
    required int fileId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.fileManagerResolveDownloadUrl(fileId.toString()),
      );

      final body = response.data ?? const {};
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid resolve-download-url payload'));
      }

      final url = data['url'];
      if (url is! String || url.trim().isEmpty) {
        return Result.failure(Failure('Invalid resolve-download-url response'));
      }

      return Result.success(url);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to resolve download url');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to resolve download url',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
