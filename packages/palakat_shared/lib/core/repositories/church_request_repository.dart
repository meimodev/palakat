import 'package:palakat_shared/core/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_shared/core/services/socket_service.dart';

part 'church_request_repository.g.dart';

@riverpod
ChurchRequestRepository churchRequestRepository(Ref ref) {
  return ChurchRequestRepository(ref);
}

class ChurchRequestRepository {
  final Ref _ref;

  ChurchRequestRepository(this._ref);

  Future<Result<ChurchRequest, Failure>> createChurchRequest({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('churchRequest.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid church request response payload'),
        );
      }
      return Result.success(ChurchRequest.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ChurchRequest?, Failure>> getMyChurchRequest() async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('churchRequest.my');
      final data = body['data'];
      if (data == null) {
        return Result.success(null);
      }
      if (data is! Map<String, dynamic>) {
        return Result.failure(
          Failure('Invalid church request response payload'),
        );
      }

      return Result.success(ChurchRequest.fromJson(data));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<PaginationResponseWrapper<ChurchRequest>, Failure>>
  fetchChurchRequests({required PaginationRequestWrapper request}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('admin.churchRequest.list', {
        'page': request.page,
        'pageSize': request.pageSize,
      });
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => ChurchRequest.fromJson(e as Map<String, dynamic>),
      );

      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> deleteChurchRequest(int id) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('admin.churchRequest.delete', {'id': id});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
