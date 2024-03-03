import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  HomeState build() {
    return HomeState(pageController: PageController(initialPage: 0));
  }

  void navigateTo(int index) async {
    await state.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    state = state.copyWith(selectedBottomNavIndex: index);
  }

  void setCurrentBackPressTime(DateTime value) {
    state = state.copyWith(currentBackPressTime: value);
  }
}
