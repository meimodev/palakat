import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/membership.dart';

// bagusnya kalo ada contract le, jdi for testing lebe banya entry case.
// cuman kalo sampe repository pake bagitu le, smo tamba banya boilerplate
// jdi ini langsung implementasi class biasa
class MembershipRepository {
  final MembershipApiContract _membershipApi;

  MembershipRepository(this._membershipApi);

  Future<Result<Membership, Failure>> getMembership(int membershipId) async {
      final result = await _membershipApi.getMembership(membershipId);
      return result.mapTo(onSuccess: Membership.fromJson) ;
  }
}

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  return MembershipRepository(ref.read(membershipApiProvider));
});
