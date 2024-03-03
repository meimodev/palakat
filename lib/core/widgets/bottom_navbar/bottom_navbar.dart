import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/constants/constants.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPressedItem,
  });

  final int currentIndex;
  final Function(int) onPressedItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BottomNavBarItem(
          onPressed: () {
            onPressedItem(0);
          },
          activated: currentIndex == 0,
          icon: Assets.icons.line.home,
        ),
        Gap.w48,
        BottomNavBarItem(
          onPressed: () {
            onPressedItem(1);
          },
          activated: currentIndex == 1,
          icon: Assets.icons.line.hospital,
        ),
        Gap.w48,
        BottomNavBarItem(
          onPressed: () {
            onPressedItem(2);
          },
          activated: currentIndex == 2,
          icon: Assets.icons.line.home,
        ),
      ],
    );
  }
}
