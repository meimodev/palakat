import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/column_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/church.dart';
import '../models/column.dart' as cm;
import '../models/location.dart';
import '../models/member_position.dart';
import '../models/member_position_detail.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';

part 'church_repository.g.dart';

@riverpod
ChurchRepository churchRepository(Ref ref) => ChurchRepository(ref);

class ChurchRepository {
  ChurchRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Church>, Failure>> fetchChurches({
    required PaginationRequestWrapper<GetFetchChurchesRequest>
    paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.churches,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Church.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch churches');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch churches', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Church, Failure>> fetchChurchProfile(int churchId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.church(churchId: churchId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?["data"] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid church response payload'));
      }

      return Result.success(Church.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch church profile');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to fetch church profile',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Church, Failure>> updateChurchProfile({
    required int churchId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.church(churchId: churchId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?["data"] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update church response payload'),
        );
      }
      return Result.success(Church.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update church profile');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to update church profile',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Location, Failure>> fetchLocation(int locationId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.location(locationId: locationId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?["data"] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid location response payload'));
      }

      return Result.success(Location.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch location');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch location', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Location, Failure>> updateLocation({
    required int locationId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.location(locationId: locationId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update location response payload'),
        );
      }

      return Result.success(Location.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update location');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update location', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<cm.Column, Failure>> updateColumn({
    required int columnId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.column(columnId: columnId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update column response payload'),
        );
      }

      return Result.success(cm.Column.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update column');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update column', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<ColumnDetail, Failure>> fetchColumn({
    required int columnId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.column(columnId: columnId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid column response payload'));
      }
      return Result.success(ColumnDetail.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch column');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch column', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<cm.Column, Failure>> createColumn({
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.columns,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create column response payload'),
        );
      }
      return Result.success(cm.Column.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create column');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create column', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> deleteColumn({required int columnId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.column(columnId: columnId));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete column');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete column', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<PaginationResponseWrapper<cm.Column>, Failure>> fetchColumns({
    required PaginationRequestWrapper<GetFetchColumnsRequest> paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.columns,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => cm.Column.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch columns');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch columns', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<List<MemberPosition>, Failure>> fetchPositions({
    required int churchId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membershipPositions,
        queryParameters: {'churchId': churchId, 'pageSize': 100},
      );

      final data = response.data;
      final List<dynamic> jsonList = (data?['data'] as List?) ?? const [];
      final positions = jsonList
          .map((e) => MemberPosition.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(positions);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch positions');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch positions', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<MemberPositionDetail, Failure>> fetchPosition({
    required int positionId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membershipPosition(positionId: positionId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid position response payload'));
      }
      return Result.success(MemberPositionDetail.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch position');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch position', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> deletePosition({
    required int positionId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(
        Endpoints.membershipPosition(positionId: positionId),
      );
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete position');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete position', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<MemberPosition, Failure>> updateMemberPosition({
    required int positionId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.membershipPosition(positionId: positionId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update position response payload'),
        );
      }

      return Result.success(MemberPosition.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update position');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update position', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<MemberPosition, Failure>> createMemberPosition({
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.membershipPositions,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create position response payload'),
        );
      }
      return Result.success(MemberPosition.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create position');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create position', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
