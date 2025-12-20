import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/services/http_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'church_request_repository.g.dart';

@riverpod
ChurchRequestRepository churchRequestRepository(Ref ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ChurchRequestRepository(httpService);
}

class ChurchRequestRepository {
  final HttpService _httpService;

  ChurchRequestRepository(this._httpService);

  Future<Result<ChurchRequest, Failure>> createChurchRequest({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _httpService.post('/church-request', data: data);

      final churchRequest = ChurchRequest.fromJson(response.data['data']);
      return Result.success(churchRequest);
    } on DioException catch (e) {
      return Result.failure(
        Failure(
          e.response?.data['message'] ?? 'Failed to submit church request',
        ),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<ChurchRequest?, Failure>> getMyChurchRequest() async {
    try {
      final response = await _httpService.get('/church-request/my-request');

      if (response.data['data'] == null) {
        return Result.success(null);
      }

      final churchRequest = ChurchRequest.fromJson(response.data['data']);
      return Result.success(churchRequest);
    } on DioException catch (e) {
      return Result.failure(
        Failure(
          e.response?.data['message'] ?? 'Failed to fetch church request',
        ),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<PaginationResponseWrapper<ChurchRequest>, Failure>>
  fetchChurchRequests({required PaginationRequestWrapper request}) async {
    try {
      final response = await _httpService.get(
        '/admin/church-requests',
        queryParameters: {'page': request.page, 'pageSize': request.pageSize},
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => ChurchRequest.fromJson(e as Map<String, dynamic>),
      );

      return Result.success(result);
    } on DioException catch (e) {
      return Result.failure(
        Failure(
          e.response?.data['message'] ?? 'Failed to fetch church requests',
        ),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<void, Failure>> deleteChurchRequest(int id) async {
    try {
      await _httpService.delete('/church-request/$id');
      return Result.success(null);
    } on DioException catch (e) {
      return Result.failure(
        Failure(
          e.response?.data['message'] ?? 'Failed to delete church request',
        ),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }
}
