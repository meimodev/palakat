import 'package:halo_hermina/features/food_menu_request/domain/food_menu_request_model.dart';

class FoodMenuRequestState {
  final List<FoodMenuRequestModel> requests;

  FoodMenuRequestState({
    required this.requests,
  });

  FoodMenuRequestState copyWith({
    List<FoodMenuRequestModel>? requests,
  }) =>
      FoodMenuRequestState(
        requests: requests ?? this.requests,
      );
}
