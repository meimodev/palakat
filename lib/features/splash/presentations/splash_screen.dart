import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

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
    controller.init(() {
      context.goNamed(AppRoute.home);
    });
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
