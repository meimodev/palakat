import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'food_menu_request_additional_state.dart';

class FoodMenuRequestAdditionalController
    extends StateNotifier<FoodMenuRequestAdditionalState> {
  FoodMenuRequestAdditionalController()
      : super(FoodMenuRequestAdditionalState());

  final String additionalFoodContact = '08123456789';
  final List<Map<String, dynamic>> additionalFoodMenu = [
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
    {
      'title': 'Additional Menu With Complete Fruits',
      'price': 48000,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661677425561-ac8dda0082b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
    },
  ];
}

final foodMenuRequestAdditionalControllerProvider =
    StateNotifierProvider.autoDispose<FoodMenuRequestAdditionalController,
        FoodMenuRequestAdditionalState>((ref) {
  return FoodMenuRequestAdditionalController();
});
