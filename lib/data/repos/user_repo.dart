import 'package:palakat/data/models/model_mock.dart';
import 'package:palakat/data/models/user.dart';

abstract class UserRepoContract {
  Future<User> getUser();
}

class UserRepo implements UserRepoContract {
  var user = ModelMock.user;

  @override
  Future<User> getUser() async {
    return user;
  }
}
