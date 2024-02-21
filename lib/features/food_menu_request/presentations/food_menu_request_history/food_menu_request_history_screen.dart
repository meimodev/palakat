import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

Map<String, dynamic> _patientMenu = {
  "morning": {
    "package": "Set B Patient Morning",
    "descriptions": [
      "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
      "Bread filled with Srikaya",
    ],
    "image":
        "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
  },
  "afternoon": {
    "package": "Set A Patient Afternoon",
    "descriptions": [
      "Strawberry, Beef Black Pepper, Vegetable Soup",
      "Strawberry Pudding",
    ],
    "image":
        "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
  },
  "evening": {
    "package": "Set A Patient Evening",
    "descriptions": [
      "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
      "Water Melon",
    ],
    "image":
        "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
  },
};

Map<String, dynamic> _companionMenu = {
  "morning": {
    "package": "Set B Comp Morning",
    "descriptions": [
      "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
      "Bread filled with Srikaya",
    ],
    "image":
        "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
  },
  "afternoon": {
    "package": "Set A Comp Afternoon",
    "descriptions": [
      "Strawberry, Beef Black Pepper, Vegetable Soup",
      "Strawberry Pudding",
    ],
    "image":
        "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
  },
  "evening": {
    "package": "Set A Comp Evening",
    "descriptions": [
      "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
      "Water Melon",
    ],
    "image":
        "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
  },
};

class FoodMenuRequestHistoryScreen extends ConsumerWidget {
  const FoodMenuRequestHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldWidget(
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: "13 July 2023",
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap.customGapHeight(10),
            CardWidget(
              title: LocaleKeys.text_patientMeal.tr(),
              titleStyle: TypographyTheme.textLSemiBold.toNeutral80,
              content: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodMenuRequestMealItemCard(
                      header: LocaleKeys.text_morning.tr(),
                      marginTop: const SizedBox(),
                      imageUrl: _patientMenu['morning']['image'],
                      title: _patientMenu['morning']['package'],
                      description: _patientMenu['morning']['descriptions'],
                      useRadio: false,
                    ),
                    FoodMenuRequestMealItemCard(
                      header: LocaleKeys.text_afternoon.tr(),
                      imageUrl: _patientMenu['afternoon']['image'],
                      title: _patientMenu['afternoon']['package'],
                      description: _patientMenu['afternoon']['descriptions'],
                    ),
                    FoodMenuRequestMealItemCard(
                      header: LocaleKeys.text_evening.tr(),
                      imageUrl: _patientMenu['evening']['image'],
                      title: _patientMenu['evening']['package'],
                      description: _patientMenu['evening']['descriptions'],

                    ),
                  ],
                ),
              ],
            ),
            Gap.customGapHeight(16),
            CardWidget(
              title: LocaleKeys.text_companionMeal.tr(),
              titleStyle: TypographyTheme.textLSemiBold.toNeutral80,
              content: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodMenuRequestMealItemCard(
                      header: LocaleKeys.text_morning.tr(),
                      marginTop: const SizedBox(),
                      imageUrl: _companionMenu['morning']['image'],
                      title: _companionMenu['morning']['package'],
                      description: _companionMenu['morning']['descriptions'],
                    ),
                    FoodMenuRequestMealItemCard(
                      header: LocaleKeys.text_afternoon.tr(),
                      imageUrl: _companionMenu['afternoon']['image'],
                      title: _companionMenu['afternoon']['package'],
                      description: _companionMenu['afternoon']['descriptions'],
                    ),
                    FoodMenuRequestMealItemCard(
                      header: LocaleKeys.text_evening.tr(),
                      imageUrl: _companionMenu['evening']['image'],
                      title: _companionMenu['evening']['package'],
                      description: _companionMenu['evening']['descriptions'],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

