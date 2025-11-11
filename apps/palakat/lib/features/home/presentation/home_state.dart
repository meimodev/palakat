import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(0) final int selectedBottomNavIndex,
    final DateTime? currentBackPressTime,
    required final PageController pageController,
  }) = _HomeState;
}
