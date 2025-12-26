import 'package:palakat_shared/core/models/column_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/church.dart';
import '../models/column.dart' as cm;
import '../models/location.dart';
import '../models/member_position.dart';
import '../models/member_position_detail.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

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
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('church.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Church.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Church, Failure>> fetchChurchProfile(int churchId) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('church.get', {'id': churchId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid church response payload'));
      }

      return Result.success(Church.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Church, Failure>> updateChurchProfile({
    required int churchId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('church.update', {
        'id': churchId,
        'dto': update,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update church response payload'),
        );
      }
      return Result.success(Church.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Location, Failure>> fetchLocation(int locationId) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('location.get', {'id': locationId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid location response payload'));
      }

      return Result.success(Location.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Location, Failure>> updateLocation({
    required int locationId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('location.update', {
        'id': locationId,
        'dto': update,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update location response payload'),
        );
      }

      return Result.success(Location.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<cm.Column, Failure>> updateColumn({
    required int columnId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('column.update', {
        'id': columnId,
        'dto': update,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update column response payload'),
        );
      }

      return Result.success(cm.Column.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ColumnDetail, Failure>> fetchColumn({
    required int columnId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('column.get', {'id': columnId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid column response payload'));
      }
      return Result.success(ColumnDetail.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<cm.Column, Failure>> createColumn({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('column.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create column response payload'),
        );
      }
      return Result.success(cm.Column.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> deleteColumn({required int columnId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('column.delete', {'id': columnId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<PaginationResponseWrapper<cm.Column>, Failure>> fetchColumns({
    required PaginationRequestWrapper<GetFetchColumnsRequest> paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('column.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => cm.Column.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<List<MemberPosition>, Failure>> fetchPositions({
    required int churchId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('membershipPosition.list', {
        'churchId': churchId,
        'page': 1,
        'pageSize': 100,
      });
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => MemberPosition.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result.data);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<MemberPositionDetail, Failure>> fetchPosition({
    required int positionId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('membershipPosition.get', {
        'id': positionId,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid position response payload'));
      }
      return Result.success(MemberPositionDetail.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> deletePosition({
    required int positionId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('membershipPosition.delete', {'id': positionId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<MemberPosition, Failure>> updateMemberPosition({
    required int positionId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('membershipPosition.update', {
        'id': positionId,
        'dto': update,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update position response payload'),
        );
      }

      return Result.success(MemberPosition.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<MemberPosition, Failure>> createMemberPosition({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('membershipPosition.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create position response payload'),
        );
      }
      return Result.success(MemberPosition.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
