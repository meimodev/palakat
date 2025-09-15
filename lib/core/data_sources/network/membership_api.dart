import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/data_sources/network/dio_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_api.g.dart';

@riverpod
class MembershipApi extends _$MembershipApi implements MembershipApiContract {
  @override
  MembershipApiContract build() {
    return this;
  }

  DioClient get _dio => ref.read(dioClientProvider());

  @override
  Future<Result<Map<String, dynamic>, Failure>> getMembership(int membershipId) async {
    try {
      final response = await _dio.get("${Endpoint.membership}/$membershipId");
      return Result.success(response['data']);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
