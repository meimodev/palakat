import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class BottomNavBarItem extends StatelessWidget {
  const BottomNavBarItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.onPressed,
  });

  Key get widgetKey => Key('bottom_nav_bar_item_$index');

  final int index;
  final int currentIndex;
  final void Function(int) onPressed;

  List<Widget> get _unselectedICon => [
        Assets.icons.line.home.svg(
          colorFilter: BaseColor.neutral.shade50.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.line.calendarDays.svg(
          colorFilter: BaseColor.neutral.shade50.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.line.healthGraph.svg(
          colorFilter: BaseColor.neutral.shade50.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.line.notification.svg(
          colorFilter: BaseColor.neutral.shade50.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.line.account.svg(
          colorFilter: BaseColor.neutral.shade50.filterSrcIn,
          height: BaseSize.h24,
        ),
      ];

  List<Widget> get _selectedIcon => [
        Assets.icons.fill.home.svg(
          colorFilter: BaseColor.primary3.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.fill.calendarDays.svg(
          colorFilter: BaseColor.primary3.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.fill.healthGraph.svg(
          colorFilter: BaseColor.primary3.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.fill.notification.svg(
          colorFilter: BaseColor.primary3.filterSrcIn,
          height: BaseSize.h24,
        ),
        Assets.icons.fill.account.svg(
          colorFilter: BaseColor.primary3.filterSrcIn,
          height: BaseSize.h24,
        ),
      ];

  bool get _isSelected => currentIndex == index;

  Widget get _icon =>
      _isSelected ? _selectedIcon[index] : _unselectedICon[index];

  List<String> get _title => [
        "Home",
        "Appointment",
        "Patient Portal",
        "Notification",
        "Account",
      ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: widgetKey,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        onTap: () => onPressed(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon,
            Gap.h8,
            Text(
              _title[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isSelected
                    ? BaseColor.primary3
                    : BaseColor.neutral.shade50,
                fontSize: BaseSize.customFontSize(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
