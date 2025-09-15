import 'package:palakat/core/data_sources/network/model/result.dart';

abstract class MembershipApiContract {

  Future<Result<Map<String, dynamic>, Failure>> getMembership(int membershipId);
}