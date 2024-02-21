import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_history/widgets/widgets.dart';

class MenuListSummaryWidget extends StatelessWidget {
  const MenuListSummaryWidget({
    super.key,
    required this.listTitle,
    required this.onPressedChange,
    required this.menus,
  });

  final String listTitle;
  final Map<String, dynamic> menus;
  final void Function() onPressedChange;

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      postFixWidget: ButtonWidget.text(
        padding: EdgeInsets.zero,
        text: LocaleKeys.text_change.tr(),
        onTap: onPressedChange,
      ),
      title: listTitle,
      titleStyle: TypographyTheme.textLSemiBold.toNeutral80,
      content: [
        for (int i = 0; i < menus.keys.length; i++)
          FoodMenuRequestMealItemCard(
            header: i == 0
                ? LocaleKeys.text_morning.tr()
                : i == 1
                ? LocaleKeys.text_afternoon.tr()
                : LocaleKeys.text_evening.tr(),
            marginTop: i == 0 ?  const SizedBox() : null,
            title: menus[menus.keys.toList()[i]]["package"],
            description: menus[menus.keys.toList()[i]]["descriptions"],
          ),
      ],
    );
  }
}
