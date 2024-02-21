import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

import 'widgets/widgets.dart';

class FoodMenuRequestSummaryScreen extends ConsumerWidget {
  const FoodMenuRequestSummaryScreen({
    super.key,
    this.showCompanionsMeal = true,
  });

  final bool showCompanionsMeal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(foodMenuRequestSummaryControllerProvider.notifier);
    // final state = ref.watch(foodMenuRequestSummaryControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_foodRequestSummary.tr(),
        height: BaseSize.customHeight(70),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListSummaryWidget(
                    listTitle: LocaleKeys.text_patientMeal.tr(),
                    menus: controller.menuSummaryPatient,
                    onPressedChange: () => context.pop(),
                  ),
                  Gap.h16,
                  showCompanionsMeal
                      ? MenuListSummaryWidget(
                          listTitle: LocaleKeys.text_companionMeal.tr(),
                          menus: controller.menuSummaryCompanion,
                          onPressedChange: () => context.pop(),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          BottomActionWrapper(
            actionButton: ButtonWidget.primary(
              onTap: () => context.pushNamed(AppRoute.foodMenuRequest),
              text: LocaleKeys.text_submit.tr(),
            ),
          ),
        ],
      ),
    );
  }
}
