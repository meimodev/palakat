import 'package:palakat/core/data_sources/network/model/model.dart';

abstract class MembershipApiContract {

  Future<Result<Map<String, dynamic>>> getMembership(String membershipId);
}