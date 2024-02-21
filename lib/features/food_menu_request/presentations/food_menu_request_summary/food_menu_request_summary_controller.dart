import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class FoodMenuRequestSummaryController extends StateNotifier<FoodMenuRequestSummaryState>{
  FoodMenuRequestSummaryController(): super(const FoodMenuRequestSummaryState());

  final Map<String, dynamic> menuSummaryPatient = {
    "morning": {
      "package": "Set A Patient Morning",
      "descriptions": [
        "Banana, Beef Blackpapper",
        "Vegetable Soup",
      ],
    },
    "afternoon": {
      "package": "Set B Patient Afternoon",
      "descriptions": [
        "Banana, Beef Blackpapper",
        "Vegetable Soup",
      ],
    },
    "evening": {
      "package": "Set C Patient Evening",
      "descriptions": [
        "Banana, Beef Blackpapper",
        "Vegetable Soup",
      ],
    },
  };

  final Map<String, dynamic> menuSummaryCompanion = {
    "morning": {
      "package": "Set A Comp Morning",
      "descriptions": [
        "Banana, Beef Blackpapper",
        "Vegetable Soup",
      ],
    },
    "afternoon": {
      "package": "Set B Comp Afternoon",
      "descriptions": [
        "Banana, Beef Blackpapper",
        "Vegetable Soup",
      ],
    },
    "evening": {
      "package": "Set C Comp Evening",
      "descriptions": [
        "Banana, Beef Blackpapper",
        "Vegetable Soup",
      ],
    },
  };

}


final foodMenuRequestSummaryControllerProvider = StateNotifierProvider.autoDispose<
    FoodMenuRequestSummaryController, FoodMenuRequestSummaryState>((ref) {
  return FoodMenuRequestSummaryController();
});
