import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/services/firestrore_services.dart';
import 'package:palakat/data/models/membership.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/shared/shared.dart';

abstract class UserRepoContract {
  Future<UserApp> readUser(String phone);
}

class UserRepo implements UserRepoContract {
  UserApp? _user ;
  final firestore = FirestoreService();

  UserApp get user {
    if (_user != null) {
      return _user!;
    }
    throw Exception("No User logged in");
  }

  @override
  Future<UserApp> readUser(
    String phoneOrId, {
    bool populateWholeData = true,
  }) async {
    final res = await firestore.getUser(phoneOrId: phoneOrId);
    final data = UserApp.fromMap(res as Map<String, dynamic>);
    _user = data;
    if (populateWholeData && _user!.membership == null) {
      await readMembership(_user!.membershipId);
    }
    if (populateWholeData &&
        _user!.membership!.church == null &&
        populateWholeData) {
      await readChurch(_user!.membership!.churchId);
    }
    return _user!;
  }

  Future<UserApp> updateUser(UserApp user) async {
    await firestore.updateUser(user.toMap);
    return user;
  }

  Future<UserApp> readMembership(String membershipId) async {
    final res = await firestore.getMembership(id: membershipId);
    final data = Membership.fromMap(res as Map<String, dynamic>);
    _user!.membership = data;
    return _user!;
  }

  Future<UserApp> readChurch(String churchId) async {
    final res = await firestore.getChurch(id: churchId);
    final data = Church.fromMap(res as Map<String, dynamic>);
    _user!.membership!.church = data;
    return _user!;
  }

  Future<UserApp> createUser({
    required DateTime dob,
    required String phone,
    required String name,
    required String maritalStatus,
  }) async {

    final newUser = UserApp(
      dob: dob.resetTimeToStartOfTheDay(),
      phone: phone,
      name: name.toTitleCase(),
      maritalStatus: maritalStatus,
    );
    final res = await firestore.setUser(newUser.toMap);
    final data = UserApp.fromMap(res as Map<String, dynamic>);
    return data;
  }
}
