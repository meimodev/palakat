import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/constants/constants.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPressedItem,
    required this.globalKeyThree,
    required this.globalKeyFour,
  });

  static const String _key = 'bottom_nav_bar';
  static const Key widgetKey = Key(_key);

  final int currentIndex;
  final Function(int) onPressedItem;
  final GlobalKey globalKeyThree;
  final GlobalKey globalKeyFour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            offset: const Offset(0, 7),
            blurRadius: 18,
            spreadRadius: -4,
          )
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: BaseSize.w8,
        elevation: 0,
        child: Wrap(
          children: [
            SizedBox(
              height: BaseSize.customHeight(70),
              key: widgetKey,
              child: Row(
                children: [
                  BottomNavBarItem(
                    index: 0,
                    currentIndex: currentIndex,
                    onPressed: onPressedItem,
                  ),
                  BottomNavBarItem(
                    index: 1,
                    currentIndex: currentIndex,
                    onPressed: onPressedItem,
                  ),
                  BottomNavBarItem(
                    key: globalKeyThree,
                    index: 2,
                    currentIndex: currentIndex,
                    onPressed: onPressedItem,
                  ),
                  BottomNavBarItem(
                    key: globalKeyFour,
                    index: 3,
                    currentIndex: currentIndex,
                    onPressed: onPressedItem,
                  ),
                  BottomNavBarItem(
                    index: 4,
                    currentIndex: currentIndex,
                    onPressed: onPressedItem,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
