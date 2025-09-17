import 'package:palakat/core/data_sources/network/model/result.dart';
import 'package:palakat/core/models/membership.dart';

abstract class MembershipApiContract {

  Future<Result<Map<String, dynamic>, Failure>> getMembership(int membershipId);
  Future<Result<Map<String, dynamic>?, Failure>> getSignedInMembership();
  Future<Result<Map<String, dynamic>, Failure>> signInMembership(Membership membershipData);

}