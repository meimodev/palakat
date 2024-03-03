import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'splash_state.dart';

class SplashController extends StateNotifier<SplashState> {
  SplashController() : super(SplashState());

  void init(void Function() onProceed) async {
    await Future.delayed(const Duration(seconds: 1));
    onProceed();
  }
}

final splashControllerProvider =
    StateNotifierProvider.autoDispose<SplashController, SplashState>(
  (ref) => SplashController(),
);
