import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/data_sources/network/dio_client.dart';
import 'package:palakat/core/models/membership.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_api.g.dart';

@riverpod
class MembershipApi extends _$MembershipApi implements MembershipApiContract {
  @override
  MembershipApiContract build() {
    return this;
  }

  DioClient get _dio => ref.read(dioClientProvider());

  HiveService get _hive => ref.read(hiveServiceProvider);

  @override
  Future<Result<Map<String, dynamic>, Failure>> getMembership(
    int membershipId,
  ) async {
    try {
      final response = await _dio.get("${Endpoint.membership}/$membershipId");
      return Result.success(response['data']);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>?, Failure>> getSignedInMembership() async {
    try {
      final membership = _hive.getMembership();
      if (membership != null) {
        return Result.success(membership.toJson());
      }
      final account = _hive.getAccount();

      if (account == null || account.membershipId == null) {
        return Result.success(null);
      }

      final response = await _dio.get(
        "${Endpoint.membership}/${account.membershipId}",
      );
      return Result.success(response['data']);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> signInMembership(Membership membership) async{
    try {
      _hive.saveMembership(membership);
      return Result.success(membership.toJson());
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
