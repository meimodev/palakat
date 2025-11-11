import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'splash_controller.g.dart';

@riverpod
class SplashController extends _$SplashController {
  @override
  SplashState build() {
    return SplashState();
  }

  void init(void Function() onProceed) async {
    await Future.delayed(const Duration(seconds: 1));
    onProceed();
  }
}