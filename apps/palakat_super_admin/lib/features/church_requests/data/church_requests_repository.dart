import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/church_request.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';
import 'package:palakat_shared/core/services/socket_service.dart';

import '../../auth/application/super_admin_auth_controller.dart';

final churchRequestsRepositoryProvider = Provider<ChurchRequestsRepository>((
  ref,
) {
  final socket = ref.watch(superAdminSocketServiceProvider);
  return ChurchRequestsRepository(socket: socket);
});

class ChurchRequestsRepository {
  ChurchRequestsRepository({required this.socket});

  final SocketService socket;

  String _requestStatusToApi(RequestStatus status) {
    switch (status) {
      case RequestStatus.todo:
        return 'TODO';
      case RequestStatus.doing:
        return 'DOING';
      case RequestStatus.done:
        return 'DONE';
      case RequestStatus.rejected:
        return 'REJECTED';
    }
  }

  Future<PaginationResponseWrapper<ChurchRequest>> fetchChurchRequests({
    required int page,
    required int pageSize,
    String? search,
    RequestStatus? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null) 'status': _requestStatusToApi(status),
      if (sortBy != null && sortBy.trim().isNotEmpty) 'sortBy': sortBy.trim(),
      if (sortOrder != null && sortOrder.trim().isNotEmpty)
        'sortOrder': sortOrder.trim(),
    };

    final data = await socket.rpc('admin.churchRequest.list', query);
    return PaginationResponseWrapper.fromJson(
      data,
      (e) => ChurchRequest.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<ChurchRequest> fetchChurchRequest(int id) async {
    final body = await socket.rpc('admin.churchRequest.get', {'id': id});
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Invalid response');
    }
    return ChurchRequest.fromJson(data);
  }

  Future<void> approve({required int id, String? decisionNote}) async {
    final payload = <String, dynamic>{
      if (decisionNote != null && decisionNote.trim().isNotEmpty)
        'decisionNote': decisionNote.trim(),
    };
    await socket.rpc('admin.churchRequest.approve', {'id': id, 'dto': payload});
  }

  Future<void> reject({required int id, required String decisionNote}) async {
    final trimmed = decisionNote.trim();
    if (trimmed.isEmpty) {
      throw StateError('Decision note is required');
    }
    await socket.rpc('admin.churchRequest.reject', {
      'id': id,
      'dto': {'decisionNote': trimmed},
    });
  }
}
