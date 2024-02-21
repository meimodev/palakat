import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/food_menu_request/domain/enums/food_menu_request_status_enum.dart';
import 'package:halo_hermina/features/food_menu_request/domain/food_menu_request_model.dart';
import 'package:halo_hermina/features/presentation.dart';

import 'widgets/widgets.dart';

class FoodMenuRequestScreen extends ConsumerWidget {
  const FoodMenuRequestScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.read(foodMenuRequestControllerProvider.notifier);
    final state = ref.watch(foodMenuRequestControllerProvider);

    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: BaseColor.neutral.shade0,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_foodMenuRequest.tr(),
      ),
      body: Column(
        children: [
          Gap.h20,
          Text(
            LocaleKeys.text_pleaseKindlyChooseYourMealAt.tr(),
            style: TypographyTheme.textMRegular.toNeutral70,
            textAlign: TextAlign.center,
          ),
          Text(
            '00.00 - 12.00 WIB',
            style: TypographyTheme.textMRegular.toNeutral70,
            textAlign: TextAlign.center,
          ),
          Gap.customGapHeight(30),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w24,
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: state.requests.length + 1,
                itemBuilder: (_, index) {
                  if (index == state.requests.length) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: BaseSize.customHeight(30),
                      ),
                      child: ButtonWidget.outlined(
                        text: LocaleKeys.text_additionalFoodMenu.tr(),
                        icon: Assets.icons.line.box.svg(
                          colorFilter: BaseColor.primary3.filterSrcIn,
                        ),
                        onTap: () => context
                            .pushNamed(AppRoute.foodMenuRequestAdditional),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: BaseSize.h12),
                    child: FoodMenuRequestListItemWidget(
                      foodMenuRequest: state.requests[index],
                      onPressedItemFoodMenuRequest:
                          (FoodMenuRequestModel data) {
                        if (data.status == FoodMenuRequestStatus.ordered) {
                          context.pushNamed(AppRoute.foodMenuRequestHistory);
                          return;
                        }
                        if (data.status == FoodMenuRequestStatus.open) {
                          context
                              .pushNamed(AppRoute.foodMenuRequestWithCompanion);
                          return;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
