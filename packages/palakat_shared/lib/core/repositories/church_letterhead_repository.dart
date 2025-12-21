import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/church_letterhead.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';

part 'church_letterhead_repository.g.dart';

@riverpod
ChurchLetterheadRepository churchLetterheadRepository(Ref ref) {
  // ignore: deprecated_member_use
  ref.keepAlive();
  return ChurchLetterheadRepository(ref);
}

class ChurchLetterheadRepository {
  ChurchLetterheadRepository(this._ref);

  final Ref _ref;

  Future<Result<ChurchLetterhead?, Failure>> fetchMyLetterhead() async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.churchLetterheadMe,
      );

      final body = response.data ?? const {};
      final data = body['data'];
      if (data == null) {
        return Result.success(null);
      }
      if (data is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid church letterhead payload'));
      }
      return Result.success(ChurchLetterhead.fromJson(data));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch letterhead');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch letterhead', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<ChurchLetterhead, Failure>> updateMyLetterhead({
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.put<Map<String, dynamic>>(
        Endpoints.churchLetterheadMe,
        data: data,
      );

      final body = response.data ?? const {};
      final json = body['data'];
      if (json is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid update letterhead payload'));
      }

      return Result.success(ChurchLetterhead.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update letterhead');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update letterhead', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<ChurchLetterhead, Failure>> uploadLogo({
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await http.post<Map<String, dynamic>>(
        Endpoints.churchLetterheadMeLogo,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = response.data ?? const {};
      final json = body['data'];
      if (json is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid upload logo response payload'));
      }

      return Result.success(ChurchLetterhead.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to upload logo');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to upload logo', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
