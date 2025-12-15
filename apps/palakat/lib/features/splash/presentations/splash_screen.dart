import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize on next frame to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashControllerProvider, (previous, next) {
      if (!next.isInitialized) return;

      // Always navigate to home - dashboard handles auth check
      context.goNamed(AppRoute.home);
    });

    return ScaffoldWidget(
      child: Center(
        child: Text(context.l10n.appTitle, style: BaseTypography.headlineSmall),
      ),
    );
  }
}
