import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/food_menu_request/domain/enums/food_menu_request_status_enum.dart';
import 'package:halo_hermina/features/food_menu_request/domain/food_menu_request_model.dart';
import 'food_menu_request_state.dart';

final List<FoodMenuRequestModel> _requests = [
  FoodMenuRequestModel(
    status: FoodMenuRequestStatus.skipped,
    date: '10 July 2023',
  ),
  FoodMenuRequestModel(
    status: FoodMenuRequestStatus.ordered,
    date: '11 July 2023',
  ),
  FoodMenuRequestModel(
    status: FoodMenuRequestStatus.ordered,
    date: '12 July 2023',
  ),
  FoodMenuRequestModel(
    status: FoodMenuRequestStatus.open,
    date: '13 July 2023',
  ),
];

class FoodMenuRequestController extends StateNotifier<FoodMenuRequestState> {
  FoodMenuRequestController()
      : super(FoodMenuRequestState(requests: _requests));

  void setRequests(List<FoodMenuRequestModel> requests) {
    state = state.copyWith(requests: requests);
  }
}

final foodMenuRequestControllerProvider = StateNotifierProvider.autoDispose<
    FoodMenuRequestController, FoodMenuRequestState>(
  (ref) {
    return FoodMenuRequestController();
  },
);
