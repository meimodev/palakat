import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/card/card_widget.dart';
import 'package:halo_hermina/features/food_menu_request/domain/enums/food_menu_request_status_enum.dart';
import 'package:halo_hermina/features/food_menu_request/domain/food_menu_request_model.dart';

class FoodMenuRequestListItemWidget extends StatelessWidget {
  const FoodMenuRequestListItemWidget({
    super.key,
    required this.foodMenuRequest,
    required this.onPressedItemFoodMenuRequest,
  });

  final FoodMenuRequestModel foodMenuRequest;
  final void Function(FoodMenuRequestModel foodMenuRequest)
      onPressedItemFoodMenuRequest;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? textColor;
    String? text;
    Widget? icon;
    switch (foodMenuRequest.status) {
      case FoodMenuRequestStatus.open:
        text = LocaleKeys.text_chooseYourMealForTomorrow.tr();
        textColor = BaseColor.primary4;
        backgroundColor = BaseColor.primary1;
        break;
      case FoodMenuRequestStatus.skipped:
        text = LocaleKeys.text_youDidNotChoseYourMeal.tr();
        break;
      case FoodMenuRequestStatus.ordered:
        text = LocaleKeys.text_youHaveChosenYourMeal.tr();
        icon = Assets.icons.line.done
            .svg(colorFilter: BaseColor.primary4.filterSrcIn);
        break;
    }

    return CardWidget(
      backgroundColor: backgroundColor ?? BaseColor.neutral.shade10,
      onTap: () => onPressedItemFoodMenuRequest(foodMenuRequest),
      content: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  foodMenuRequest.date,
                  style: TypographyTheme.heading4SemiBold.copyWith(
                    color: textColor ?? BaseColor.neutral.shade60,
                  ),
                ),
                icon ?? const SizedBox(),
              ],
            ),
            Text(
              text,
              style: TypographyTheme.textSRegular.toNeutral60,
            ),
          ],
        ),
      ],
    );
  }
}
