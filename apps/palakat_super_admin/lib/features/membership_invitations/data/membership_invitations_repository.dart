import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/palakat_shared.dart';

import '../../auth/application/super_admin_auth_controller.dart';

final membershipInvitationsRepositoryProvider =
    Provider<MembershipInvitationsRepository>((ref) {
      final socket = ref.watch(superAdminSocketServiceProvider);
      return MembershipInvitationsRepository(socket: socket);
    });

class MembershipInvitationsRepository {
  MembershipInvitationsRepository({required this.socket});

  final SocketService socket;

  Future<PaginationResponseWrapper<MembershipInvitation>>
  fetchMembershipInvitations({
    required int page,
    required int pageSize,
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    final data = await socket.rpc('admin.membershipInvitation.list', query);
    return PaginationResponseWrapper.fromJson(
      data,
      (e) => MembershipInvitation.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<MembershipInvitation> fetchMembershipInvitation(int id) async {
    final body = await socket.rpc('admin.membershipInvitation.get', {'id': id});
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Invalid response');
    }
    return MembershipInvitation.fromJson(data);
  }

  Future<MembershipInvitation> approve({required int id}) async {
    final body = await socket.rpc('admin.membershipInvitation.approve', {
      'id': id,
    });
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Invalid response');
    }
    return MembershipInvitation.fromJson(data);
  }

  Future<MembershipInvitation> reject({
    required int id,
    String? rejectedReason,
  }) async {
    final payload = <String, dynamic>{
      'id': id,
      if (rejectedReason != null && rejectedReason.trim().isNotEmpty)
        'rejectedReason': rejectedReason.trim(),
    };
    final body = await socket.rpc('admin.membershipInvitation.reject', payload);
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Invalid response');
    }
    return MembershipInvitation.fromJson(data);
  }

  Future<void> delete({required int id}) async {
    await socket.rpc('admin.membershipInvitation.delete', {'id': id});
  }
}
