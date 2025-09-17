import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/membership.dart';

part 'membership_repository.g.dart';

@riverpod
class MembershipRepository extends _$MembershipRepository {
  @override
  MembershipRepository build() {
    return this;
  }

  MembershipApiContract get _membershipApi => ref.read(membershipApiProvider);

  Future<Result<Membership, Failure>> getMembership(int membershipId) async {
    final result = await _membershipApi.getMembership(membershipId);
    return result.mapTo(onSuccess: Membership.fromJson);
  }

  Future<Result<Membership?, Failure?>> getSignedInMembership() async {
    final result = await _membershipApi.getSignedInMembership();
    return result.mapTo<Membership?, Failure?>(
      onSuccess: (data) => data == null ? null : Membership.fromJson(data),
    );
  }

  Future<Result<Membership, Failure>> signInMembership(
    Membership membership,
  ) async {
    final result = await _membershipApi.signInMembership(membership);
    return result.mapTo<Membership, Failure>(onSuccess: Membership.fromJson);
  }
}
