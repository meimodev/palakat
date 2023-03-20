import 'package:firebase_auth/firebase_auth.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/services/firestrore_services.dart';
import 'package:palakat/data/models/membership.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/data/services/phone_auth_service.dart';
import 'package:palakat/shared/shared.dart';
import 'dart:developer' as dev;

abstract class UserRepoContract {
  Future<UserApp> readUser(String phone);
}

//TODO Fix the error when accessing a null user if the user not yet registered
//TODo check the phone version to accomodate that

class UserRepo implements UserRepoContract {
  static UserApp? _user;

  final firestore = FirestoreService();
  final phoneAuthService = PhoneAuthService();
  final auth = FirebaseAuth.instance;

  String verificationID = "";

  Future<UserApp> user() async {
    if (_user != null) {
      dev.log("[UserRepo] USING CACHED USER");
      return _user!;
    }

    if (auth.currentUser == null) {
      throw Exception("[UserRepo] NO PHONE VERIFIED FOR FIREBASE");
    }

    return await readUser(auth.currentUser!.phoneNumber!);
  }

  @override
  Future<UserApp> readUser(
    String phoneOrId, {
    bool populateWholeData = true,
  }) async {
    Object? res;
    if (phoneOrId.startsWith("08") || phoneOrId.startsWith("+62")) {
      res = await firestore.getUserByPhone(phone: phoneOrId);
    } else {
      res = await firestore.getUserById(userId: phoneOrId);
    }
    final data = UserApp.fromMap(res as Map<String, dynamic>);
    _user = data;

    if (populateWholeData &&
        _user!.membershipId.isNotEmpty ) {
      _user!.membership = await readMembership(_user!.membershipId);
    }

    if (_user!.membership == null) {
      return _user!;
    }

    if (populateWholeData && _user!.membership!.church == null) {
      _user!.membership!.church = await readChurch(_user!.membership!.churchId);
    }

    return _user!;
     
  }

  Future<UserApp> updateUser(UserApp user) async {
    await firestore.updateUser(user.toMap);
    return user;
  }

  Future<Membership?> readMembership(String membershipId) async {
    final res = await firestore.getMembership(id: membershipId);
    if (res == null) {
      return null;
    }
    return Membership.fromMap(res as Map<String, dynamic>);
  }

  Future<Church?> readChurch(String churchId) async {
    final res = await firestore.getChurch(id: churchId);
    if (res == null) {
      return null;
    }
    return Church.fromMap(res as Map<String, dynamic>);
  }

  Future<UserApp> createUser({
    required DateTime dob,
    required String phone,
    required String name,
    required String maritalStatus,
  }) async {
    final newUser = UserApp(
      dob: dob.resetTimeToStartOfTheDay(),
      phone: phone.cleanPhone(useCountryCode: true),
      name: name.toTitleCase(),
      maritalStatus: maritalStatus,
    );
    final res = await firestore.setUser(newUser.toMap);
    final data = UserApp.fromMap(res as Map<String, dynamic>);
    return data;
  }

  Future<String> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(UserApp user) onProceed,
    required void Function(String phone, String userId) onRegister,
    required void Function() onManualCodeVerification,
    required void Function(String firebaseAuthExceptionCode) onFailed,
  }) async {
    bool shouldCallFromIdTokenChangesListenerOccurred = true;
    auth.authStateChanges().listen((User? user) async {
      const logHeadText = "[UserRepo] authStateChanges()";
      shouldCallFromIdTokenChangesListenerOccurred = false;
      if (user != null) {
        dev.log('$logHeadText, Phone number confirmed');

        final result = await firestore.getUserByPhone(phone: user.phoneNumber!);
        final userApp = result != null
            ? UserApp.fromMap(result as Map<String, dynamic>)
            : null;

        if (userApp != null) {
          signUser(userApp);
          dev.log('$logHeadText signed success $_user');
          onProceed(userApp);
          return;
        }

        onRegister(user.phoneNumber!, user.uid);
        _user = null;
        dev.log(
            '$logHeadText  Phone verified but not registered yet ${user.phoneNumber} $userApp');
        return;
      }
      dev.log('$logHeadText user = null');
      _user = null;
    });
    auth.idTokenChanges().listen((user) async {
      //just called this listener when the auth status is never called
      if (!shouldCallFromIdTokenChangesListenerOccurred) {
        return;
      }

      const logHeadText = "[UserRepo] idTokenChanges()";

      if (user != null) {
        dev.log('$logHeadText, Phone number confirmed');
        if (_user != null) {
          dev.log('$logHeadText user already signed');
          return;
        }
        final result = await firestore.getUserByPhone(phone: user.phoneNumber!);
        final userApp = result != null
            ? UserApp.fromMap(result as Map<String, dynamic>)
            : null;

        if (userApp != null) {
          signUser(userApp);
          dev.log('$logHeadText signed success $_user');
          onProceed(userApp);
          return;
        }

        // user is not registered
        onRegister(user.phoneNumber!, user.uid);
        _user = null;

        dev.log('$logHeadText Phone verified but not registered yet $user');
        return;
      }

      dev.log("$logHeadText Phone not confirmed");
    });

    await phoneAuthService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onManualCodeVerification: (String verificationID) {
        this.verificationID = verificationID;
        onManualCodeVerification();
      },
      onFailed: onFailed,
      onSuccessAuth: (String sentCode) {
        dev.log("[UserRepo] OTP code automatically retrieved");
      },
    );
    return "";
    
  }

  Future<void> signInWithCredential({
    required String smsCode,
    required void Function(String firebaseAuthExceptionCode) onFailed,
  }) async {
    await phoneAuthService.signInWithCredentialFromPhone(
        verificationId: verificationID, smsCode: smsCode, onFailed: onFailed);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> signUser(UserApp userApp) async {
    // commit userdata to local storage
    _user = userApp;
  }

  Future<bool> isSignedIn() async {
    //instead check in local storage
    return auth.currentUser != null;
  }
}
