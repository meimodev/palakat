import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(homeControllerProvider.notifier);
    final state = ref.watch(homeControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) {
          if (state.selectedBottomNavIndex != 0) {
            controller.navigateTo(0);
          } else {
            DateTime now = DateTime.now();

            if (state.currentBackPressTime == null ||
                now.difference(state.currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              controller.setCurrentBackPressTime(now);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Press back again to exit',
                    style: BaseTypography.titleMedium,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: PageView(
                allowImplicitScrolling: false,
                physics: const NeverScrollableScrollPhysics(),
                controller: state.pageController,
                children: const [
                  DashboardScreen(),
                  PublishingScreen(),
                  SongBookScreen(),
                  OperationsScreen(),
                  ApprovalScreen(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                currentIndex: state.selectedBottomNavIndex,
                onPressedItem: (index) {
                  controller.navigateTo(index);
                },
              ),
            ),
          ],
        ),
      ),
    );

    //Contain the bottom navbar widget
  }
}
