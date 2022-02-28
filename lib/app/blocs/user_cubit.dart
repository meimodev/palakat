import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:palakat/data/models/user.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserLoading());

  void loadUser(User user) => emit(
        UserLoaded(
          user: user,
        ),
      );
}