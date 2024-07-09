import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class MembershipApi implements MembershipApiContract {
  final memberships = FirestoreUtil.memberships;
  final accounts = FirestoreUtil.accounts;
  final churches = FirestoreUtil.churches;
  final columns = FirestoreUtil.columns;

  @override
  Future<Result<Map<String, dynamic>>> getMembership(
      String membershipSerial) async {
    final membership =
        (await memberships.doc(membershipSerial).get()).data() ?? {};
    final account =
        (await accounts.doc(membership["account_serial"]).get()).data() ?? {};
    final church =
        (await churches.doc(membership["church_serial"]).get()).data() ?? {};
    final column =
        (await columns.doc(membership["column_serial"]).get()).data() ?? {};
    return Result.success({
      ...membership,
      "account": account,
      "church": church,
      "column": column,
    });
  }
}

final membershipApiProvider = Provider<MembershipApi>((ref) {
  return MembershipApi();
});
