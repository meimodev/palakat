import 'package:palakat/data/models/membership.dart';
import 'package:palakat/data/services/firestrore_services.dart';

abstract class MembershipRepoContract {}

class MembershipRepo implements MembershipRepoContract {
  final firestore = FirestoreService();

  Future<Membership> createMembership({
    required Membership membership,
    required String userId,
  }) async {
    final res = await firestore.setMembership(membership.toMap(), userId);
    final data = Membership.fromMap(res as Map<String, dynamic>);
    return data;
  }

  Future<Membership> updateMembership(Membership membership) async {
    await firestore.updateMembership(membership.toMap());
    return membership;
  }
}
