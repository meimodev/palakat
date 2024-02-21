import 'package:halo_hermina/features/food_menu_request/domain/enums/food_menu_request_status_enum.dart';

class FoodMenuRequestModel {
  final String date;
  final FoodMenuRequestStatus status;

  FoodMenuRequestModel({
    required this.date,
    required this.status,
  });
}