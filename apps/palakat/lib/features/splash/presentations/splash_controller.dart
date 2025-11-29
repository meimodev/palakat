import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

@riverpod
class SplashController extends _$SplashController {
  @override
  SplashState build() {
    return const SplashState();
  }

  /// Initialize app and navigate to home
  /// Authentication check and data refresh are handled by DashboardController
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    // Wait for splash delay
    await Future.delayed(const Duration(seconds: 1));

    final localStorage = ref.read(localStorageServiceProvider);

    // Ensure LocalStorageService has loaded cached data
    await localStorage.init();

    // Always navigate to home - dashboard will handle auth check and data refresh
    state = state.copyWith(isLoading: false, isInitialized: true);
  }
}
