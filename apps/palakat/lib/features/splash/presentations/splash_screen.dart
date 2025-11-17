import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/services.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  SplashState get state => ref.watch(splashControllerProvider);

  SplashController get controller =>
      ref.read(splashControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Check for existing auth tokens
    final localStorageService = ref.read(localStorageServiceProvider);

    // Ensure LocalStorageService has loaded cached data
    await localStorageService.init();

    final isAuthenticated = localStorageService.isAuthenticated;
    final hasValidToken =
        localStorageService.accessToken != null &&
        localStorageService.accessToken!.isNotEmpty;

    if (isAuthenticated && hasValidToken) {
      // User has valid tokens, navigate to home
      if (mounted) {
        context.goNamed(AppRoute.home);
      }
    } else {
      // No valid tokens, navigate to authentication
      if (mounted) {
        context.goNamed(AppRoute.authentication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Center(
        child: Text("Splash Screen", style: BaseTypography.headlineSmall),
      ),
    );
  }
}
