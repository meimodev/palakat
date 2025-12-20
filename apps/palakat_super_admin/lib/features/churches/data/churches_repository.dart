import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/church.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';

import '../../auth/application/super_admin_auth_controller.dart';

final churchesRepositoryProvider = Provider<ChurchesRepository>((ref) {
  final dio = ref.watch(superAdminAuthedDioProvider);
  return ChurchesRepository(dio: dio);
});

class ChurchesRepository {
  ChurchesRepository({required this.dio});

  final Dio dio;

  static const Object notProvided = Object();

  Future<PaginationResponseWrapper<Church>> fetchChurches({
    required int page,
    required int pageSize,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (sortBy != null && sortBy.trim().isNotEmpty) 'sortBy': sortBy.trim(),
      if (sortOrder != null && sortOrder.trim().isNotEmpty)
        'sortOrder': sortOrder.trim(),
    };

    final res = await dio.get<Map<String, dynamic>>(
      'admin/churches',
      queryParameters: query,
    );

    final data = res.data ?? const {};
    return PaginationResponseWrapper.fromJson(
      data,
      (e) => Church.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<Church> fetchChurch(int id) async {
    final res = await dio.get<Map<String, dynamic>>('admin/churches/$id');
    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Invalid response');
    }
    return Church.fromJson(data);
  }

  Future<Church> createChurch({
    required String name,
    required String locationName,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? email,
    String? description,
    String? documentAccountNumber,
  }) async {
    final trimmedName = name.trim();
    final trimmedLocName = locationName.trim();

    if (trimmedName.isEmpty) throw StateError('Name is required');
    if (trimmedLocName.isEmpty) throw StateError('Location name is required');

    final payload = <String, dynamic>{
      'name': trimmedName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (description != null) 'description': description,
      if (documentAccountNumber != null)
        'documentAccountNumber': documentAccountNumber,
      'location': {
        'create': {
          'name': trimmedLocName,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      },
    };

    final res = await dio.post<Map<String, dynamic>>(
      'admin/churches',
      data: payload,
    );

    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return Church.fromJson(data);
  }

  Future<Church> updateChurch({
    required int id,
    String? name,
    Object? phoneNumber = notProvided,
    Object? email = notProvided,
    Object? description = notProvided,
    Object? documentAccountNumber = notProvided,
    String? locationName,
    Object? latitude = notProvided,
    Object? longitude = notProvided,
  }) async {
    final payload = <String, dynamic>{
      if (name != null) 'name': name,
      if (phoneNumber != notProvided) 'phoneNumber': phoneNumber,
      if (email != notProvided) 'email': email,
      if (description != notProvided) 'description': description,
      if (documentAccountNumber != notProvided)
        'documentAccountNumber': documentAccountNumber,
      if (locationName != null ||
          latitude != notProvided ||
          longitude != notProvided)
        'location': {
          'update': {
            if (locationName != null) 'name': locationName,
            if (latitude != notProvided) 'latitude': latitude,
            if (longitude != notProvided) 'longitude': longitude,
          },
        },
    };

    final res = await dio.patch<Map<String, dynamic>>(
      'admin/churches/$id',
      data: payload,
    );

    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return Church.fromJson(data);
  }

  Future<void> deleteChurch(int id) async {
    await dio.delete('admin/churches/$id');
  }
}
