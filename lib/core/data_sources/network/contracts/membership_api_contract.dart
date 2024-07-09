import 'package:palakat/core/data_sources/network/model/model.dart';

abstract class MembershipApiContract {

  /// can be empty Map if membership not found
  Future<Result<Map<String, dynamic>>> getMembership(String userSerial);
}