import 'package:palakat/data/models/membership.dart';
import 'package:palakat/data/services/firestrore_services.dart';

abstract class MembershipRepoContract {}

class MembershipRepo implements MembershipRepoContract {
  final firestore = FirestoreService();

  Future<Membership> updateMembership(Membership membership) async {
    await firestore.updateMembership(membership.toMap());
    return membership;

  }
}
