import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/appbar/appbar_widget.dart';

import 'food_menu_request_additional_controller.dart';
import 'widgets/widgets.dart';

class FoodMenuRequestAdditionalScreen extends ConsumerWidget {
  const FoodMenuRequestAdditionalScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(foodMenuRequestAdditionalControllerProvider.notifier);

    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: BaseColor.neutral.shade0,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_additionalFoodMenu.tr(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.h20,
        ),
        child: Column(
          children: [
            Gap.h20,
            RichText(
              text: TextSpan(
                text: LocaleKeys.text_forOrderAdditionalFoodContact.tr(),
                style: TypographyTheme.textMSemiBold.toNeutral60,
                children: <TextSpan>[
                  TextSpan(
                    text: controller.additionalFoodContact,
                    style: TypographyTheme.textMSemiBold.toPrimary,
                  ),
                ],
              ),
            ),
            Gap.customGapHeight(30),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: BaseSize.w12,
                  mainAxisSpacing: BaseSize.h12,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height /
                          1.5),
                ),
                itemCount: controller.additionalFoodMenu.length,
                itemBuilder: (_, index) {
                  final menu = controller.additionalFoodMenu[index];
                  return FoodMenuItemGridCardWidget(
                    imageUrl: menu['imageUrl'] ?? "",
                    title: menu['title'] ?? "",
                    price: menu['price'] ?? 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
