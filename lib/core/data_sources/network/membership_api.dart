import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/data_sources/network/dio_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class MembershipApi implements MembershipApiContract {
  final DioClient _dio;

  MembershipApi(this._dio);

  @override
  Future<Result<Map<String, dynamic>>> getMembership(String membershipId) async {
    try {
      final response = await _dio.get(
        "${Endpoint.membership}/$membershipId",
      );
      return Result.success(
        response['data']
      );
    } catch (e, st) {
      NetworkExceptions.fromDioException(e, st);
      return Result.failure(
        e,
        st,
      );
    }
  }
}

final membershipApiProvider = Provider<MembershipApi>((ref) {
  return MembershipApi(ref.read(dioClientProvider));
});
